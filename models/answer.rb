class Answer < ActiveRecord::Base
  has_many :comments, as: :commentable
  belongs_to :userlogin, class_name: "UserLogin", foreign_key: "user_id"
  belongs_to :question
end
