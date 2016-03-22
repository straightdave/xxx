require 'digest'

class User < ActiveRecord::Base
  module Status
    NEWBIE  = 0 # just signed up, no mail-validated yet; can only sign in
    NORMAL  = 1 # normal, can do almost everything now
    SUSPEND = 2 # like newbie; NORMAL => SUSPEND if changed email, etc.
    BANNED  = 3 # even cannot sign in; no profile/works accessible
    REMOVED = 4 # removed from db sooner or later in db refine routine
  end

  module Role
    USER       = 0
    MODERATOR  = 1
    ADMIN      = 8
    SUPERADMIN = 9
  end

  # === mixins ===
  include Reportability

  # === associations ===
  has_one :info, class_name: "UserInfo"
  has_many :inbox_messages, class_name: "Message", foreign_key: "to_uid"

  # questions, answers and articles provided by this user
  has_many :answers
  has_many :articles
  has_many :asked_questions, class_name: "Question"

  # users that follow such user, and users whom such user follows
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

  # watched questions
  has_and_belongs_to_many :watched_questions, -> { uniq },
                          class_name: "Question",
                          join_table: "watching_list",
                          foreign_key: "user_id",
                          association_foreign_key: "question_id"

  # user <-> organization
  has_and_belongs_to_many :organization, -> { uniq },
                          join_table: "user_organization",
                          class_name: "Organization",
                          foreign_key: "user_id",
                          association_foreign_key: "organization_id"

  # user events
  has_many :events

  # relations between users and tags, so-called 'expertises'
  has_many :expertises

  has_many :reports, as: :reportable

  # medals user earned
  has_and_belongs_to_many :medals, -> { uniq },
                          join_table: "user_medal",
                          foreign_key: "user_id",
                          association_foreign_key: "medal_id"

  # organization
  belongs_to :organization

  # === validations ===
  validates :login_name,
            format: { with: /\A[0-9a-zA-Z_]+\z/ },
            presence: true,
            length: { in: 3 .. 15 },
            uniqueness: true

  validates :email, presence: true, uniqueness: true

  # === helpers ===
  def url
    "/u/#{self.login_name}"
  end

  def set_password(input_password)
    salt = Time.now.hash.to_s[ -6 .. -1 ]
    self.salt     = salt
    self.password = add_salt(input_password, salt)
  end

  def authenticate(input_password)
    self.password == add_salt(input_password, salt)
  end

  def gen_and_set_new_vcode
    temp = Time.now.hash.to_s[ -6 .. -1 ]
    self.vcode = Digest::MD5.hexdigest(self.login_name + temp)
  end

  def self.validate(id, code)
    if (user = User.find_by(id: id)) &&
       (user.status == Status::NEWBIE) &&
       (code == user.vcode)
      user.status = Status::NORMAL
      if user.valid?
        user.save
        return true
      end
    end
    false
  end

  def update_reputation(delta)
    self.reputation += delta
    save if valid?
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
    when :ask      then 1
    when :answer   then 2
    when :comment  then 3
    when :compose  then 4
    when :vote     then 5
    when :devote   then 6
    when :watch    then 7
    when :unwatch  then 8
    when :follow   then 9
    when :unfollow then 10
    when :update   then 11
    when :accept   then 12
    else 0
    end

    target_type_id = case
    when target_obj.is_a?(Question) then 1
    when target_obj.is_a?(Answer)   then 2
    when target_obj.is_a?(Comment)  then 3
    when target_obj.is_a?(Article)  then 4
    when target_obj.is_a?(User)     then 5  # update profile without param 'obj'
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

  def admin?
    self.role == Role::ADMIN || self.role == Role::SUPERADMIN
  end

  # privileges check
  def can_change_email
    self.status == Status::NEWBIE || self.status == Status::NORMAL
  end

  private
  def add_salt(passwd, salt)
    Digest::MD5.hexdigest(passwd << salt)
  end
end
