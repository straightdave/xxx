# provide mixins for all votable objects
module Votability
  def scores
    return @t_score unless @t_score.nil?

    @t_scores = 0
    votes.each { |v| @t_scores += v.points } if votes && !votes.empty?
    @t_scores
  end

  def scores=(new_val)
    @t_score = new_val
  end

  # when object get voted, author will get some praises:
  # update reputation and all corresponding expertises
  def get_voted
    self.author.info.update_reputation(2)
    self.author.expertises.where(tag_id: get_tids).all.each do |e|
      e.voted_once
    end
  end

  def get_devoted
    self.author.info.update_reputation(-2)
    self.author.expertises.where(tag_id: get_tids).all.each do |e|
      e.voted_once
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
