class Event < ActiveRecord::Base
  # == fields ==
  # id
  # event_type (1-ask; 2-answer; 3-comment; 4-compose; 5-vote; 6-devote;
  #             7-watch; 8-unwatch; 9-follow; 10-unfollow; 11-update_profile;
  #             12-accept;)
  # target_type (1-question; 2-answer; 3-comment; 4-article; 5-user)
  # target_id
  # created_at

  # == associations ==
  belongs_to :user

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
    else
      nil
    end
  end

  def event_type_zh
    case self.event_type
    when 1 then "提出"
    when 2 then "回答"
    when 3 then "评论"
    when 4 then "发表"
    when 5 then "投票给"
    when 6 then "踩了"
    when 7 then "收藏"
    when 8 then "取消收藏"
    when 9 then "关注"
    when 10 then "取关"
    when 11 then "修改"
    when 12 then "采纳"
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

end
