class Question < ActiveRecord::Base

  # == associations ==
  # the accepted_answer foreign key is in question mod, so use 'belongs_to'
  belongs_to :accepted_answer, class_name: "Answer",
                               foreign_key: "accepted_answer_id"

  # record the lastest doer (commentor, answerer, asker)
  # other fields: last_do_type, last_do_at
  belongs_to :last_doer, class_name: "User", foreign_key: "last_doer_id"

  has_many :comments, as: :commentable
  has_many :votes, as: :votable
  has_many :answers

  # user who asked this question
  # fk 'user_id' is in this model,so use 'belongs_to'
  belongs_to :asker, class_name: "User", foreign_key: "user_id"

  # one question can have multiple tags
  # one tag can appach to multiple questions
  has_and_belongs_to_many :tags,
                          join_table: "question_tag",
                          class_name: "Tag",
                          foreign_key: "question_id",
                          association_foreign_key: "tag_id"

  # questions can be watched by users, n:n
  has_and_belongs_to_many :watchers,
                          join_table: "watching_list",
                          class_name: "User",
                          foreign_key: "question_id",
                          association_foreign_key: "user_id",
                          readonly: true,
                          autosave: false,
                          validate: false

  # == validates ==
  # some other restrictions wrote in controller
  validates :title, :content, presence: true
  validates :title, length: { maximum: 300, too_long: "标题请勿超过300字符" }

  # == helpers ==
  def scores
    @scores = 0
    votes.each {|v| @scores += v.points} if votes && !votes.empty?
    @scores
  end

  def scores=(new_val)
    @score = new_val
  end

end
