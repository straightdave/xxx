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

  # == validations ==
  validates :name, length: { maximum: 50, too_long: "名字请勿超过50字符" }
  validates :desc, length: { maximum: 100, too_long: "描述请勿超过100字符" }

  # == helpers ==
  def self.top(number)
    Tag.order(used: :desc).take(number)
  end

  def self.ft_search(keys)
    search_str = keys.join(" ")
    Tag.where("MATCH (name,`desc`) AGAINST ( ? IN NATURAL LANGUAGE MODE )",
              search_str)
  end

  def self.ft_search_name(keys, limit = 10)
    search_str = keys.join(" ")
    Tag.where("MATCH (name) AGAINST ( ? IN NATURAL LANGUAGE MODE )",
              search_str).take(limit)
  end
end
