# ajax call for vote/devote one stuff
post %r{/([q|a|c])/(\d+)/(devote|vote)} do |target_type, id, behavior|
  login_filter
  user = User.find_by(id: session[:user_id])

  obj = case target_type
  when "a" then Answer.find_by(id: id)
  when "c" then Comment.find_by(id: id)
  when "q" then Question.find_by(id: id)
  end
  return (json ret: "error", msg: "投票对象有误") unless obj

  if obj.author.id == user.id
    return json ret: "error", msg: "不可以给自己投票哦"
  end

  return (json ret: "error", msg: "我已经投过票了") if already_voted?(obj)

  if behavior == "vote"
    if user.reputation > 15
      vote = obj.votes.build(voter: user)
      vote.points = 1
      obj.get_voted
    else
      return json ret: "error", msg: "声望要超过15才可以顶哦"
    end
  elsif behavior == "devote"
    if user.reputation > 125
      vote = obj.votes.build(voter: user)
      vote.points = -1
      obj.get_devoted
    else
      return json ret: "error", msg: "声望要超过125才可以踩哦"
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
