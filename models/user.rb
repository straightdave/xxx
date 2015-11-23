class User < ActiveRecord::Base
  self.table_name = "users"
  self.primary_key = "user_id"

  # === associations ===
  # detailed info of user
  has_one :info, class_name: "UserInfo", foreign_key: "user_id"

  # all answers gived by user
  has_many :answers

  # user asks, answers and watchs questions
  # user also can comment, but no need to refer to comments from users
  has_many :asked_questions, class_name: "Question"
  has_many :answered_questions, class_name: "Question", through: :answers
  has_and_belongs_to_many :watching_questions,
                          class_name: "Question",
                          join_table: "watching_list",
                          foreign_key: "user_id",
                          association_foreign_key: "question_id"

  # === validations ===
  # some should be provided
  validates :login_email, :passwd, :salt, presence: true

  # login with an email
  email_regex = /\A\s*(([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})[\s\/,;]*)+\Z/i
  validates :login_email, format: { with: email_regex }, uniqueness: true

  validates :passwd, length: { in: 6..20 }
end
