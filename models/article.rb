class Article < ActiveRecord::Base
  # === associations ===
  has_many :comments, as: :commentable
  has_many :votes, as: :votable

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

  # == add mixins as a votable obj ==
  include Votability
end