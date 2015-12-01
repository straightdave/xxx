post %r{/([q|a])/(\d+)/comment} do |target, id|
  return (json ret: "error", msg: "need_login") unless login?

  obj = case target
  when "q"
    Question.find_by(id: id)
  when "a"
    Answer.find_by(id: id)
  end

  return (json ret: "error", msg: "target_not_found") unless obj

  unless author = User.find_by(user_id: session[:user_id])
    return json ret: "error", msg: "user_not_found"
  end

  content = params['content']
  c = Comment.new
  c.author = author
  c.content = content
  obj.comments << c
  obj.watchers << author if target == "q"

  if c.valid? && obj.valid?
    c.save    # c will be autosaved?
    obj.save
    json ret: "success", msg: c.id
  else
    json ret: "error", msg: obj.errors.messages.inspect
  end
end
