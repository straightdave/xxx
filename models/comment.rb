class Comment < ActiveRecord::Base

  # == associations ==
  belongs_to :commentable, polymorphic: true
  belongs_to :author, class_name: "User", foreign_key: "user_id"

end
