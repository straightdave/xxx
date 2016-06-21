post %r{/([q|a|c|article])/(\d+)/(downvote|vote)} do |type, id, act|
  user = login_filter

  obj = case type
  when "a" then
    Answer.find_by(id: id)
  when "c" then
    Comment.find_by(id: id)
  when "q" then
    Question.find_by(id: id)
  end
  return (json ret: "error", msg: "获取投票对象出错") unless obj

  if obj.user_id == user.id
    return json ret: "error", msg: "不可以给自己投票哦"
  end

  return (json ret: "error", msg: "你已经给这个投过票了") if user.already_voted?(obj)

  if act == "vote"
    if user.reputation >= 15 || settings.ignore_repu_limit
      obj.votes.create(voter: user, points: 1, votee_id: obj.user_id)
      obj.get_voted
    else
      return json ret: "error", msg: "声望不足，请参考声望权限说明"
    end
  elsif act == "downvote"
    if user.reputation >= 125 || settings.ignore_repu_limit
      obj.votes.create(voter: user, points: -1, votee_id: obj.user_id)
      obj.get_downvoted
      user.update_reputation(-1) # downvoter should be punished, too
    else
      return json ret: "error", msg: "声望不足，请参考声望权限说明"
    end
  else
    return json ret: "error", msg: "未知的动作"
  end

  user.record_event(act.to_sym, obj)
  json ret: "success", msg: obj.scores
end
