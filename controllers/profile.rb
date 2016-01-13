# ====== user profile actions ======
# update own profile
post '/user/profile' do
  unless user = User.find_by(id: session[:user_id])
    return json ret: "error", msg: "need_login"
  end

  user.info.nickname = params['nickname']
  user.info.email = params['email']
  user.info.intro = params['intro']
  user.info.contact = params['contact']
  user.info.city = params['city']

  if user.info.valid?
    user.info.save
    json ret: "success"
  else
    json ret: "error", msg: user.info.errors.messages.inspect
  end
end

# view one's own profile
get '/user/profile' do
  redirect to('/login?r=' + CGI.escape('/user/profile')) unless login?

  unless @user = User.find_by(id: session[:user_id])
    return (json ret: "error", msg: "account_error")
  end

  @title = "我的资料"
  @user_info = @user.info
  erb :own_profile
end

# view other's profile
get '/u/:name' do |name|
  unless @user = User.find_by(login_name: name)
    raise not_found
  end

  @user_info = @user.info
  @title = @user_info.nickname
  @followed = @user.followers.exists?(session[:user_id]) if login?
  @lastest_actions = @user.lastest_actions(10)
  erb :user_profile
end

# upload avatar files (maybe any file)
post '/upload' do
  return (json ret: "error", msg: "need_login") unless login?

  unless params['file'] &&
         (tmpfile = params[:file][:tempfile]) &&
         (name = params[:file][:filename])
    return json ret: "error", msg: "no_file"
  end

  ext = name.split('.')[-1]
  unless ["jpeg", "jpg", "png"].include? ext
    return json ret: "error", msg: "invalid_file_ext|#{ext}"
  end

  if tmpfile.size > 50 * 1024
    return json ret: "error", msg: "file_too_big|#{tmpfile.size}"
  end

  login_name = session[:login_name]
  avatar_file_name = "#{login_name}"    # no ext for quick access
  full_name = "#{settings.public_folder}/uploads/avatars/#{avatar_file_name}"

  File.open(full_name, "w+") do |file|
    file.puts tmpfile.read
  end

  begin
    user_info = UserInfo.find_by(user_id: session[:user_id])
    user_info.avatar = "/uploads/avatars/#{avatar_file_name}"
    user_info.save
    json ret: "success", msg: full_name
  rescue
    json ret: "error", msg: $0.inspect
  end

  # for now, redirect to current page
  redirect to("/user/profile")
end
