# ajax call for vote/devote one stuff
post %r{/([q|a|c])/(\d+)/(devote|vote)} do |target_type, id, behavior|
  return (json ret: "error", msg: "need_login") unless login?

  obj = case target_type
  when "a" then Answer.find_by(id: id)
  when "c" then Comment.find_by(id: id)
  when "q" then Question.find_by(id: id)
  end
  return (json ret: "error", msg: "target_not_found") unless obj

  unless user = User.find_by(id: session[:user_id])
    return json ret: "error", msg: "user_not_found"
  end

  return (json ret: "error", msg: "already_voted") if already_voted?(obj)

  vote = obj.votes.build(voter: user)

  if behavior == "vote"
    vote.points = 1
    obj.get_voted
  elsif behavior == "devote"
    vote.points = -1
    obj.get_devoted
  end

  if vote.valid? && obj.valid?
    vote.save && obj.save
    json ret: "success", msg: obj.scores
  else
    json ret: "error", msg: obj.errors.messages.inspect
  end
end
