class Answer < ActiveRecord::Base
  # == associations ==
  has_many :comments, as: :commentable
  has_many :votes, as: :votable
  has_many :reports, as: :reportable
  belongs_to :author, class_name: "User", foreign_key: "user_id"
  belongs_to :question

  # == validations ==
  validates :content, length: { maximum: 500, too_long: "回答需要言简意赅，不要超过500字哦" }

  # == helpers ==
  def url
    "/q/#{self.question.id}#a#{self.id}"
  end

  # == add mixins as a votable obj ==
  include Votability
end
