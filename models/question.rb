class Question < ActiveRecord::Base
  has_many :comments, as: :commentable
  has_many :answers
  belongs_to :userlogin, class_name: "UserLogin", foreign_key: "user_id"
  has_and_belongs_to_many :tags, join_table: "q_tag",
                                 class_name: "Tag",
                                 foreign_key: "q_id",
                                 association_foreign_key: "t_id"

  def accepted_answer
    if accepted_answer_id == 0
      nil
    else
      Answer.find_by(id: accepted_answer_id)
    end
  end

  def last_doer
    UserLogin.find_by(user_id: last_doer_id)
  end
end
