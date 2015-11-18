class UserLogin < ActiveRecord::Base
  self.table_name = "user_login"
  self.primary_key = "user_id"

  has_one :userinfo, class_name: "UserInfo", foreign_key: "user_id"
  has_many :questions
  has_many :answers
  has_many :comments

  email_regex = /\A\s*(([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})[\s\/,;]*)+\Z/i

  validates :login_email, :passwd, :salt, presence: true
  validates :login_email, format: { with: email_regex }
end
