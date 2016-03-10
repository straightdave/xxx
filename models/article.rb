class Article < ActiveRecord::Base
  # === associations ===
  has_many :comments, as: :commentable
  has_many :votes, as: :votable
  has_many :reports, as: :reportable

  # user who asked this question
  # fk 'user_id' is in this model,so use 'belongs_to'
  belongs_to :author, class_name: "User", foreign_key: "user_id"

  # one article can have multiple tags
  # one tag can appach to multiple articles
  has_and_belongs_to_many :tags, -> { uniq },
                          join_table: "article_tag",
                          class_name: "Tag",
                          foreign_key: "article_id",
                          association_foreign_key: "tag_id"

  # == validations ==
  validates :title, length: { maximum: 100, too_long: "标题请勿超过100字符" }
  validates :content, length: { maximum: 5000, too_long: "正文请勿超过1000字符" }

  # == helpers ==
  def url
    "/a/#{self.id}"
  end

  # == add mixins as a votable obj ==
  include Votability
end
