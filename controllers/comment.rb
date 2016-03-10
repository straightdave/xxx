post %r{/([q|a|w])/(\d+)/comment} do |target, id|
  return (json ret: "error", msg: "need_login") unless login?

  obj = case target
  when 'q' then Question.find_by(id: id)
  when 'a' then Answer.find_by(id: id)
  when 'w' then Article.find_by(id: id)
  else nil  # TODO: other commentable here, maybe articles, news ...
  end

  return (json ret: "error", msg: "target_not_found") unless obj

  unless author = User.find_by(id: session[:user_id])
    return json ret: "error", msg: "user_not_found"
  end

  if author.reputation < 10
    return json ret: "error", msg: "repu_cannot_comment"
  end

  content = params['content']
  c = Comment.new
  c.author = author
  c.content = content
  obj.comments << c
  obj.watchers << author if target == "q"

  if c.valid? && obj.valid?
    c.save && obj.save
    author.update_reputation(1)

    # new event recording method,
    # be aware of the target saved is the stuff which get commented
    author.record_event(:comment, obj)
    json ret: "success", msg: c.id
  else
    json ret: "error", msg: obj.errors.messages.inspect
  end
end
