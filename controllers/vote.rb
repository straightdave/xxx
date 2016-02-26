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

  if obj.author.id == user.id
    return json ret: "error", msg: "no_vote_self"
  end

  return (json ret: "error", msg: "already_voted") if already_voted?(obj)

  if behavior == "vote"
    if user.reputation > 15
      vote = obj.votes.build(voter: user)
      vote.points = 1
      obj.get_voted
    else
      return json ret: "error", msg: "repu_cannot_vote"
    end
  elsif behavior == "devote"
    if user.reputation > 125
      vote = obj.votes.build(voter: user)
      vote.points = -1
      obj.get_devoted
    else
      return json ret: "error", msg: "repu_cannot_devote"
    end
  end

  if vote.valid? && obj.valid?
    vote.save && obj.save
    user.record_event(behavior.to_sym, obj)
    json ret: "success", msg: obj.scores
  else
    json ret: "error", msg: obj.errors.messages.inspect
  end
end
