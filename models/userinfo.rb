class UserInfo < ActiveRecord::Base
  self.table_name = "user_info"

  belongs_to :user
  validates :nickname, presence: true
end
