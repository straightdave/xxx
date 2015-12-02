post %r{/([q|a|c])/(\d+)/vote} do |target, id|
  return (json ret: "error", msg: "need_login") unless login?

  obj = case target
  when "q"
    Question.find_by(id: id)
  when "a"
    Answer.find_by(id: id)
  when "c"
    Comment.find_by(id: id)
  end

  return (json ret: "error", msg: "target_not_found") unless obj

  unless user = User.find_by(id: session[:user_id])
    return json ret: "error", msg: "user_not_found"
  end

  return (json ret: "error", msg: "just_voted") if already_voted?(obj)

  vote = Vote.new
  vote.voter = user

  op = params['op'] || "u"
  if op == "u"
    vote.points = 1
  elsif op == "d"
    vote.points = -1
  end

  obj.votes << vote

  if vote.valid? && obj.valid?
    vote.save
    obj.save # vote will be autosaved?
    json ret: "success", msg: obj.scores
  else
    json ret: "error", msg: obj.errors.messages.inspect
  end
end
