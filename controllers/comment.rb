post %r{/([q|a|w])/(\d+)/comment} do |target, id|
  return (json ret: "error", msg: "need_login") unless login?

  obj = case target
  when 'q'
    Question.find_by(id: id)
  when 'a'
    Answer.find_by(id: id)
  when 'w'
    Article.find_by(id: id)
  else
    nil  # TODO: other commentable here, maybe articles, news ...
  end

  return (json ret: "error", msg: "target_not_found") unless obj

  unless author = User.find_by(id: session[:user_id])
    return json ret: "error", msg: "user_not_found"
  end

  content = params['content']
  c = Comment.new
  c.author = author
  c.content = content
  obj.comments << c
  obj.watchers << author if target == "q"

  if c.valid? && obj.valid?
    c.save
    obj.save
    send_msg_after_comment(author, obj)
    add_repu(author, 1)

    HistoricalAction.create(
      user_id: session[:user_id],
      action_type: 'c',
      target_type: target,
      target_id: id,
      created_at: Time.now
    )

    json ret: "success", msg: c.id
  else
    json ret: "error", msg: obj.errors.messages.inspect
  end
end
