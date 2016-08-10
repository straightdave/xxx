post %r{/([q|a|w])/(\d+)/comment} do |target, id|
  author = login_filter

  obj = case target
  when 'q' then Question.find_by(id: id)
  when 'a' then Answer.find_by(id: id)
  when 'w' then Article.find_by(id: id)
  else nil
  end

  return (json ret: "error", msg: "target_not_found") unless obj

  if author.reputation < 1 && !settings.ignore_repu_limit
    return json ret: "error", msg: "repu_cannot_comment"
  end

  if obj.status == 1
    return json ret: "error", msg: "已关闭评论"
  end

  content = ERB::Util.h params['content']
  c = Comment.new
  c.author = author
  c.content = content
  obj.comments << c
  obj.watchers << author if target == "q"

  if obj.valid?
    obj.save
    author.record_event(:comment, obj)
    json ret: "success", msg: c.id
  else
    json ret: "error", msg: obj.errors.messages.inspect
  end
end
