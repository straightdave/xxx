class UserInfo < ActiveRecord::Base
  self.table_name = "user_info"
  self.primary_key = "id"

  # == validations ==
  validates :nickname, presence: true
end
