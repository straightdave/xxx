class Answer < ActiveRecord::Base
  # == associations ==
  has_many :comments, as: :commentable
  has_many :votes, as: :votable
  belongs_to :author, class_name: "User", foreign_key: "user_id"
  belongs_to :question

  # == validations ==
  validates :content, length: { maximum: 2000, too_long: "proceed_max_length" }

  # == helpers ==
  def url
    "/q/#{self.question.id}#a#{self.id}"
  end

  # == add mixins as a votable obj ==
  include Votability
end
