class HistoricalAction < ActiveRecord::Base
  # === associations ===
  belongs_to :user

  # === helpers ===
  def action_type_zh
    case self.action_type
    when 'a'
      "回答了"
    when 'q'
      "提问了"
    when 'c'
      "评论了"
    when 'w'
      "发表了"
    else
      "搞了"
    end
  end

  def target_type_zh
    case self.target_type
    when 'q'
      "问题"
    when 'a'
      "文章"
    else
      "某种东西"
    end
  end

  def target_url
    case target_type
    when 'q'
      "/q/#{target_id}"
    when 'a'
      "/a/#{target_id}"
    else
      "/"
    end
  end

  def target_title
    case target_type
    when 'q'
      if q = Question.find_by(id: target_id)
        q.title
      else
        "没找到id=#{target_id}的问题"
      end
    when 'a'
      if a = Article.find_by(id: target_id)
        a.title
      else
        "没找到id=#{target_id}的文章"
      end
    else
      "未知的未知"
    end
  end

end
