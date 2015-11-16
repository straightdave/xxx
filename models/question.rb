class Question < ActiveRecord::Base
  has_many :comments, as: :commentable
  belongs_to :userlogin, class_name: "UserLogin", foreign_key: "user_id"
  has_and_belongs_to_many :tags, join_table: "q_tag",
                                 class_name: "Tag",
                                 foreign_key: "q_id",
                                 association_foreign_key: "t_id"
end
