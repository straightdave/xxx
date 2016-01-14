class UserTag < ActiveRecord::Base
  self.table_name = "user_tag"
  self.primary_key = "id"

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
  # Note: just modify values without saving
  def answered_once
    answered += 1
    expert_score += 1 * 1
  end

  def get_accepted
    accepted += 1
    expert_score += 1 * 5
  end

  # vote & devote also can be used by articles
  def get_voted
    voted += 1
    expert_score += 1 * 2
  end

  def get_devoted
    devoted += 1
    expert_score -= 1 * 2
  end
end
