class Answer < ActiveRecord::Base
  # == associations ==
  has_many :comments, as: :commentable
  has_many :votes, as: :votable
  belongs_to :author, class_name: "User", foreign_key: "user_id"
  belongs_to :question

  # == validations ==
  validates :content, length: { maximum: 500, too_long: "回答请勿超过500字符" }

  # == add mixins as a votable obj ==
  include Votability
end
