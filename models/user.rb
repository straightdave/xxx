require 'digest'

class User < ActiveRecord::Base
  # === associations ===
  # detailed info of user
  has_one :info, class_name: "UserInfo"

  # inbox messages inside the site
  has_many :inbox_messages, class_name: "Message", foreign_key: "to_uid"

  # all answers gived by this user
  # for the sake of listing high praised answers
  has_many :answers

  # user asks, answers and watchs questions
  # user also can comment, but no need to refer to comments from users
  has_many :asked_questions, class_name: "Question"
  has_many :answered_questions, class_name: "Question", through: :answers
  has_and_belongs_to_many :watching_questions, -> { uniq },
                          class_name: "Question",
                          join_table: "watching_list",
                          foreign_key: "user_id",
                          association_foreign_key: "question_id"

  # user has fav tags
  has_and_belongs_to_many :fav_tags, -> { uniq },
                          class_name: "Tag",
                          join_table: "user_tag",
                          foreign_key: "user_id",
                          association_foreign_key: "tag_id"

  # === validations ===
  # login name contains only underscore, numbers and letters, no more than 50
  validates :login_name,
            format: { with: /\A[0-9a-zA-Z_]+\z/ },
            presence: true,
            length: { in: 1..50 },
            uniqueness: true

  validates :password, presence: true

  # === helpers ===
  def authenticate(input_password)
    password == add_salt(input_password, salt)
  end

  private
  def add_salt(passwd, salt)
    Digest::MD5.hexdigest(passwd << salt)
  end
end