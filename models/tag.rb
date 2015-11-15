class Tag < ActiveRecord::Base
  has_and_belongs_to_many :questions, join_table: "q_tag", foreign_key: "q_id"
end
