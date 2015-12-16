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
end
