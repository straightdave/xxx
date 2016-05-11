module Votability

  # when object get voted, author will get some praises:
  # update reputation and all corresponding expertises
  def get_voted
    self.scores += 1
    self.author.update_reputation(2)

    # only for comments
    if self.is_a?(Comment)
      # to leave a comment will not directly get the commentor expertises
      # only if such comment is voted
      get_tids().each do |tid|
        self.author.expertises.find_or_create_by(tag_id: tid)
      end
    end

    self.author.expertises.where(tag_id: get_tids).all.each do |e|
      e.voted_once
    end
  end

  def get_devoted
    self.scores -= 1
    self.author.update_reputation(-2)

    self.author.expertises.where(tag_id: get_tids).all.each do |e|
      e.devoted_once
    end
  end

  private
  def get_tids
    case
    when self.is_a?(Question) || self.is_a?(Article)
      self.tag_ids
    when self.is_a?(Answer)
      self.question.tag_ids
    when self.is_a?(Comment)
      if self.commentable.is_a?(Question) || self.commentable.is_a?(Article)
        self.commentable.tag_ids
      elsif self.commentable.is_a?(Answer)
        self.commentable.question.tag_ids
      end
    else
      []
    end
  end

end
