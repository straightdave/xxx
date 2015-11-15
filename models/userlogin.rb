class UserLogin < ActiveRecord::Base
  self.table_name = "user_login"
  self.primary_key = "user_id"

  has_one :userinfo, class_name: "UserInfo", foreign_key: "user_id"

  email_regex = %r{
    ^ # Start of string
    [0-9a-z] # First character
    [0-9a-z.+]+ # Middle characters
    [0-9a-z] # Last character
    @ # Separating character
    [0-9a-z] # Domain name begin
    [0-9a-z.-]+ # Domain name middle
    [0-9a-z] # Domain name end
    $ # End of string
  }xi # Case insensitive

  validates :login_email, :passwd, :salt, presence: true
  validates :login_email, format: { with: email_regex }
end
