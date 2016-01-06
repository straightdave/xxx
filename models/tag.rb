class Tag < ActiveRecord::Base
  # == associations ==
  # refer to all questions belongs to such tag
  has_and_belongs_to_many :questions, join_table: "question_tag",
                                      class_name: "Question",
                                      foreign_key: "tag_id",
                                      association_foreign_key: "question_id"

  # refer to all articles belongs to such tag
  has_and_belongs_to_many :articles, join_table: "article_tag",
                                     class_name: "Article",
                                     foreign_key: "tag_id",
                                     association_foreign_key: "article_id"

  # == helpers ==
  def self.top(number)
    Tag.order(used: :desc).take(number)
  end

  def self.ft_search(keys)
    # do full-text search with MySQL NGRAM ft engine
    search_str = keys.join(" ")
    Tag.find_by_sql("SELECT * FROM tags
                    WHERE MATCH (name,`desc`)
                    AGAINST ('#{search_str}'
                    IN NATURAL LANGUAGE MODE);")
  end
end
