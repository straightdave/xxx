post '/u/:name/follow' do |name|
  login_filter
  user = User.find_by(id: session[:user_id])

  unless target = User.find_by(login_name: name)
    return json ret: "error", msg: "user_not_found"
  end

  target.followers << user unless target.followers.exists?(session[:user_id])
  if target.valid?
    target.save
    user.record_event(:follow, target)
    json ret: "success"
  else
    json ret: "error", msg: target.errors.messages
  end
end

post '/u/:name/unfollow' do |name|
  login_filter
  user = User.find_by(id: session[:user_id])

  unless target = User.find_by(login_name: name)
    return json ret: "error", msg: "user_not_found"
  end

  target.followers.delete user
  if target.valid?
    target.save
    user.record_event(:unfollow, target)
    json ret: "success"
  else
    json ret: "error", msg: target.errors.messages
  end
end

get '/u/:name' do |name|
  unless @user = User.find_by(login_name: name)
    raise not_found
  end

  @user_info = @user.info
  @title     = @user_info.nickname
  @followed  = @user.followers.exists?(session[:user_id]) if login?
  @events    = @user.get_events  # top 20 by default
  erb :user_profile
end

get '/user/home' do
  login_filter

  unless @user = User.find_by(id: session[:user_id])
    raise not_found
  end

  @title = "用户首页"
  @user_info = @user.info
  @events = Event.event_of_users(@user.followee_ids)
  erb :user_home
end
