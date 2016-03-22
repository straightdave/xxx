class Event < ActiveRecord::Base
  # == fields ==
  # id
  # event_type (1-ask; 2-answer; 3-comment; 4-compose; 5-vote; 6-devote;
  #             7-watch; 8-unwatch; 9-follow; 10-unfollow; 11-update;
  #             12-accept;)
  # target_type (1-question; 2-answer; 3-comment; 4-article; 5-user)
  # target_id
  # created_at

  # == associations ==
  belongs_to :invoker, class_name: "User", foreign_key: "user_id"

  # == helper ==
  def target
    case self.target_type
    when 1
      Question.find_by(id: self.target_id)
    when 2
      Answer.find_by(id: self.target_id)
    when 3
      Comment.find_by(id: self.target_id)
    when 4
      Article.find_by(id: self.target_id)
    when 5
      User.find_by(id: self.target_id)
    else
      nil
    end
  end

  def event_type_zh
    case self.event_type
    when 1 then "提出了"
    when 2 then "回答了"
    when 3 then "评论了"
    when 4 then "发表了"
    when 5 then "顶了"
    when 6 then "踩了"
    when 7 then "收藏了"
    when 8 then "取消收藏了"
    when 9 then "关注了"
    when 10 then "取关了"
    when 11 then "修改了"
    when 12 then "采纳了"
    else ""
    end
  end

  def target_type_zh
    case self.target_type
    when 1 then "问题"
    when 2 then "回答"
    when 3 then "评论"
    when 4 then "文章"
    when 5 then "用户"
    else ""
    end
  end

  def target_title
    case
    when self.target.is_a?(Answer)
      return self.target.question.title
    when self.target.is_a?(User)
      return self.target.info.nickname
    when self.target.is_a?(Comment)
      if self.target.commentable.is_a?(Answer)
        return self.target.commentable.question.title + "的回答"
      else
        return self.target.commentable.title
      end
    end
    self.target.title
  end

  def target_url
    if self.target.is_a?(Comment)
      # this happens when voting a comment, but comment has no url
      return self.target.commentable.url
    end
    self.target.url
  end

  def target_quote
    unless self.target.is_a?(User)
      get_abstract(self.target.content, 100)
    end
  end

  # find events from several users
  def self.event_of_users(user_ids = [], limit = 50, offset = 0)
    Event.where(user_id: user_ids)
         .order(created_at: :desc)
         .limit(limit)
         .offset(offset)
  end

  private
  # this is duplicated with a helper method
  # should be a refactory
  def get_abstract(content, num_of_char)
    res = content.gsub(%r{</?[^>]+?>}, '')
    if res.size <= num_of_char
      res
    else
      res[0 .. num_of_char] + "..."
    end
  end

end
