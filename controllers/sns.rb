post '/u/:name/follow' do |name|
  unless user = User.find_by(id: session[:user_id])
    return json ret: "error", msg: "need_login"
  end

  unless target = User.find_by(login_name: name)
    return json ret: "error", msg: "user_not_found"
  end

  target.followers << user unless target.followers.exists?(session[:user_id])
  if target.valid?
    target.save
    json ret: "success"
  else
    json ret: "error", msg: target.errors.messages
  end
end

post '/u/:name/unfollow' do |name|
  unless user = User.find_by(id: session[:user_id])
    return json ret: "error", msg: "need_login"
  end

  unless target = User.find_by(login_name: name)
    return json ret: "error", msg: "user_not_found"
  end

  target.followers.delete user
  if target.valid?
    target.save
    json ret: "success"
  else
    json ret: "error", msg: target.errors.messages
  end
end
