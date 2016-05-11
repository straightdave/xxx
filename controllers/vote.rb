post %r{/([q|a|c])/(\d+)/(devote|vote)} do |target_type, id, behavior|
  user = login_filter

  case target_type
  when "a" then
    obj = Answer.find_by(id: id)
    required_vote_repu = 15
    required_devote_repu = 250
  when "c" then
    obj = Comment.find_by(id: id)
    required_vote_repu = 1
  when "q" then
    obj = Question.find_by(id: id)
    required_vote_repu = 10
    required_devote_repu = 200
  end
  return (json ret: "error", msg: "获取投票对象出错") unless obj

  if obj.user_id == user.id
    return json ret: "error", msg: "不可以给自己投票哦"
  end

  return (json ret: "error", msg: "我已经投过票了") if already_voted?(obj)

  if behavior == "vote"
    if user.reputation >= required_vote_repu || settings.ignore_repu_limit
      obj.votes.create(voter: user, points: 1)
      obj.get_voted
    else
      return json ret: "error", msg: "声望不足#{required_vote_repu}，请参考声望权限说明"
    end
  elsif behavior == "devote"
    if user.reputation >= required_devote_repu || settings.ignore_repu_limit
      obj.votes.create(voter: user, points: -1)
      obj.get_devoted
    else
      return json ret: "error", msg: "声望不足#{required_devote_repu}，请参考声望权限说明"
    end
  else
    return json ret: "error", msg: "unknown behavior"
  end

  if obj.valid?
    obj.save
    user.record_event(behavior.to_sym, obj)
    json ret: "success", msg: obj.scores
  else
    json ret: "error", msg: obj.errors.messages.inspect
  end
end
