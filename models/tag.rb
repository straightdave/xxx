class Tag < ActiveRecord::Base

  # == associations ==
  # refer to all questions attached by the tags
  has_and_belongs_to_many :questions, join_table: "question_tag",
                                      class_name: "Question",
                                      foreign_key: "tag_id",
                                      association_foreign_key: "question_id"

end
