class Comment < ActiveRecord::Base
  # == associations ==
  has_many :votes, as: :votable
  belongs_to :commentable, polymorphic: true
  belongs_to :author, class_name: "User", foreign_key: "user_id"

  # == validations ==
  validates :content, length: { maximum: 200, too_long: "评论请勿超过200字符" }

  # == add mixins as a votable obj ==
  include Votability
end
