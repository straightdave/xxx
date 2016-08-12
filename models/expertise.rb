# Joint model 'Expertise' describes relations between users and tags:
# how users are good at such tags
# user (n) : tag (n)
# also it records statistics such as number of 'answers' of such tag,
# number of 'accepted answers' of such tag, how many 'vote/downvote' in this tag
class Expertise < ActiveRecord::Base
  # == associations ==
  # to get tag object from this
  # since fk 'tag_id' is in this table, so use 'belongs_to' instead of 'has_one'
  belongs_to :tag

  # to get user object from this
  belongs_to :user

  # == helpers ==
  # there is a calculated column in this model: expert_score
  # for fault-proof, any actions to modify those columns being calculated
  # should be wrapped into methods
  def answered_once
    self.answered += 1
    self.expert_score += 1 * 1
    self.save if self.valid?
  end

  def accepted_once
    self.accepted += 1
    self.expert_score += 1 * 5
    self.save if self.valid?
  end

  # vote & downvote also can be used by articles
  def voted_once!
    self.voted += 1
    self.expert_score += 1 * 2
    self.save if self.valid?
  end

  def downvoted_once!
    self.voted += 1
    self.expert_score -= 1 * 2
    self.save if self.valid?
  end
end
