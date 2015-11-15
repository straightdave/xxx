class UserInfo < ActiveRecord::Base
  self.table_name = "user_info"
  self.primary_key = "id"

  belongs_to :userlogin, class_name: "UserLogin", foreign_key: "user_id"
  validates :user_id, presence: true
end
