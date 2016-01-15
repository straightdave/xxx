class UserInfo < ActiveRecord::Base
  self.table_name = "user_info"
  self.primary_key = "id"

  # == validations ==
  validates :nickname, presence: true

  # == helpers ==
  def update_reputation(delta)
    self.reputation += delta
    save if valid?
  end
end
