class Answer < ActiveRecord::Base

  # == associations ==
  has_many :comments, as: :commentable
  belongs_to :author, class_name: "User", foreign_key: "user_id"
  belongs_to :question

end
