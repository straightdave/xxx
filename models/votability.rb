module Votability
  # mixins for dealing with objects which get votes/downvotes

  # when object get votes/downvotes, the following things will happen:
  # 1. author's reputation
  # 2. author's expertises

  # NOTE: the public methods' names are formed as 'v + n.'
  # and the subject should be the objects which get votes/downvotes

  def get_voted!(param = {})
    return unless voter = param[:by]

    # score: redundant field for quick calculating
    # sum up total scores (all votes - all downvotes) for this obj
    self.scores += 1

    # update reputation
    self.author.update_reputation!(by: 5, since: "question got voted") if self.is_a?(Question)
    self.author.update_reputation!(by: 10, since: "answer got voted") if self.is_a?(Answer)

    # update post author's expertises
    self.author.expertises.where(tag_id: get_tag_ids).all.each do |e|
      e.voted_once!
    end

    # create vote (to record obj's all votes : by who, points and why)
    self.votes.create(voter: voter, points: 1, votee_id: self.user_id)
    self.save if valid?
  end

  def get_downvoted!(param = {})
    return unless voter = param[:by]

    self.scores -= 1
    self.author.update_reputation! by: -2, since: "post got downvoted"
    self.author.expertises.where(tag_id: get_tag_ids).all.each do |e|
      e.downvoted_once!
    end

    # downvoter should be also punished
    voter.update_reputation! by: -1, since: "downvoting something"

    self.votes.create(voter: voter, points: -1, votee_id: self.user_id)
    self.save if valid?
  end

  private
  def get_tag_ids
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
      [] # return no null
    end
  end
end
