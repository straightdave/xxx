class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :userlogin, class_name: "UserLogin", foreign_key: "user_id"
end
