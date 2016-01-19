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

  # articles
  has_many :articles

  # users that follow such users, and users whom such user follows
  has_and_belongs_to_many :followers, -> { uniq },
                          class_name: "User",
                          join_table: "followinfo",
                          foreign_key: "followee_id",
                          association_foreign_key: "follower_id"

  has_and_belongs_to_many :followees, -> { uniq },
                          class_name: "User",
                          join_table: "followinfo",
                          foreign_key: "follower_id",
                          association_foreign_key: "followee_id"

  # user asks, answers and watchs questions
  # user also can comment, but no need to refer to comments from users
  has_many :asked_questions, class_name: "Question"
  
  has_and_belongs_to_many :watching_questions, -> { uniq },
                          class_name: "Question",
                          join_table: "watching_list",
                          foreign_key: "user_id",
                          association_foreign_key: "question_id"

  # user events
  has_many :events

  # user-top association for top expert tags use
  has_many :tags, through: :expertises
  has_many :expertises

  # === validations ===
  # login name contains only underscore, numbers and letters, no more than 50
  validates :login_name,
            format: { with: /\A[0-9a-zA-Z_]+\z/ },
            presence: true,
            length: { in: 1..50 },
            uniqueness: true

  validates :password, presence: true

  # === helpers ===
  def url
    "/u/#{self.login_name}"
  end

  def set_password_and_salt(input_password, salt)
    self.salt = salt
    self.password = add_salt(input_password, salt)
  end

  def authenticate(input_password)
    self.password == add_salt(input_password, salt)
  end

  def follower_size
    followers.nil? ? 0 : followers.size
  end

  def followee_size
    followees.nil? ? 0 : followees.size
  end

  # add expertises (tags relationship), using meta-programming: send/1
  # 2 things to notice:
  # a) count add multiple tags
  # b) duplicated tags will not be added
  def add_expertise(tag_ids = [], reason)
    tag_ids.each do |tid|
      unless exp = self.expertises.find_by(tag_id: tid)
        exp = self.expertises.build(tag_id: tid)
      end
      exp.send(reason) # reason is atom of method names (voted_once, etc.)
    end
  end

  def get_expert_tag(tag_id)
    self.expertises.where(tag_id: tag_id).first
  end

  def get_expert_score(tag_id)
    self.expertises.where(tag_id: tag_id).first.expert_score
  end

  # returned object is user - tag relationship
  # can get how many answered, accepted, voted and devoted other than score
  # also can get tag model from it
  def top_expert_tags(number)
    ret = self.expertises.where("expert_score > 0").order(expert_score: :desc)
    return ret if number.nil? || number < 1
    ret.limit number
  end

  # user event recording
  # a user can use 'build' built-in method but here provided another one
  # type should be atoms: ':ask', ':answer', ':comment', ...
  def record_event(type, target_obj)
    event_type_id = case type
    when :ask then 1
    when :answer then 2
    when :comment then 3
    when :compose then 4
    when :vote then 5
    when :devote then 6
    when :watch then 7
    when :unwatch then 8
    when :follow then 9
    when :unfollow then 10
    when :update_profile then 11
    when :accept then 12
    else 0
    end

    target_type_id = case
    when target_obj.is_a?(Question) then 1
    when target_obj.is_a?(Answer) then 2
    when target_obj.is_a?(Comment) then 3
    when target_obj.is_a?(Article) then 4
    when target_obj.is_a?(User) then 5  # update own profile without param 'obj'
    else 0
    end

    event = self.events.build(
      event_type:  event_type_id,
      target_type: target_type_id,
      target_id:   target_obj.id
    )

    if event.valid?
      event.save
    else
      raise "event_recording_error"
    end
  end

  # get events, part by part
  def get_events(num_per_slice = 20, part_no = 0)
    self.events.order(created_at: :desc)
               .limit(num_per_slice)
               .offset(num_per_slice * part_no)
  end

  private
  def add_salt(passwd, salt)
    Digest::MD5.hexdigest(passwd << salt)
  end
end
