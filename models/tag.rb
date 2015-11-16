class Tag < ActiveRecord::Base
  has_and_belongs_to_many :questions, join_table: "q_tag",
                                      class_name: "Question"
                                      foreign_key: "t_id",
                                      association_foreign_key: "q_id"
end
