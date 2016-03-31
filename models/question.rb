class Question < ActiveRecord::Base
  module Status
    NORMAL    = 0
    NOCOMMENT = 1
    FROZEN    = 2
    HIDDEN    = 3
    DELETED   = 4
  end

  # == associations ==
  # the accepted_answer foreign key is in question mod, so use 'belongs_to'
  belongs_to :accepted_answer, class_name: "Answer", foreign_key: "accepted_answer_id"

  # record the lastest doer (commentor, answerer, asker)
  # other fields: last_do_type, last_do_at
  #belongs_to :last_doer, class_name: "User", foreign_key: "last_doer_id"

  has_many :comments, as: :commentable
  has_many :votes, as: :votable
  has_many :reports, as: :reportable
  has_many :answers

  # user who asked this question
  # fk 'user_id' is in this model,so use 'belongs_to'
  belongs_to :author, class_name: "User", foreign_key: "user_id"

  # one question can have multiple tags
  # one tag can appach to multiple questions
  has_and_belongs_to_many :tags, -> { uniq },
                          join_table: "question_tag",
                          class_name: "Tag",
                          foreign_key: "question_id",
                          association_foreign_key: "tag_id"


  # questions can be watched by users, n:n
  has_and_belongs_to_many :watchers, -> { uniq },
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
  validates :title, length: { maximum: 100, too_long: "标题请勿超过100字符" }
  validates :content, length: { maximum: 500, too_long: "问题请勿超过500字符" }

  # == add mixins ==
  include Votability
  include Reportability

  # == helpers ==
  def url
    "/q/#{self.id}"
  end

  def get_last_events(last_num = 1, event_type = 0)
    # target_type = 1 means questions
    result = Event.where(target_type: 1).where(target_id: self.id)

    if event_type != 0
      # event type = 0 - all kinds of events
      result = result.where(event_type: event_type)
    end
    result.order(created_at: :desc).take(last_num)
  end

  def get_last_event
    # 0 - all kinds of events
    self.get_last_events(1, 0).first
  end

  def get_last_doer
    self.get_last_event.invoker
  end

  def get_last_edit_event
    # 11 - edit events
    self.get_last_events(1, 11).first
  end

  def can_comment
    self.status == 0
  end

  def is_frozen
    self.status >= 2
  end

  def is_hidden
    self.status >= 3
  end

  def is_deleted
    self.status == 4
  end

  def self.ft_search(keys)
    # do full-text search with MySQL NGRAM ft engine
    search_str = keys.join(" ")
    Question.where("MATCH (title,content) AGAINST (? IN NATURAL LANGUAGE MODE)", search_str)
  end

  def self.ft_search_title(keys, limit = 10)
    # used in asking page
    search_str = keys.join(" ")
    Question.where("MATCH (title) AGAINST (? IN NATURAL LANGUAGE MODE)", search_str).limit(limit)
  end

  def self.ft_search_intag(keys, tag_id)
    search_str = keys.join(" ")
    Question.joins("JOIN question_tag ON question_tag.question_id = questions.id")
            .where("question_tag.tag_id = ? AND MATCH (questions.title, questions.content)
                    AGAINST (? IN NATURAL LANGUAGE MODE)", tag_id, search_str)
  end
end
