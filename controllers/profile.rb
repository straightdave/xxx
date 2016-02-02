# ====== user profile actions ======
post '/user/profile' do
  unless user = User.find_by(id: session[:user_id])
    return json ret: "error", msg: "need_login"
  end

  email_changed = user.email != params['email']
  if email_changed && !user.can_change_email
    return json ret: "error", msg: "cannot_change_email"
  end

  user.info.nickname = params['nickname']
  user.info.intro    = params['intro']
  user.info.phone    = params['contact']
  user.info.city     = params['city']
  user.info.qq       = params['qq']
  user.info.wechat   = params['wechat']
  user.info.email2   = params['email2']
  user.email         = params['email']

  if user.info.valid?
    user.info.save
    user.record_event(:update_profile, user)

    if email_changed && user.can_change_email
      user.status = User::NEWBIE
      user.gen_and_set_new_vcode
      if user.valid?
        user.save
        send_validation_mail user
      else
        return json ret: "error", msg: "resend_validation_failed"
      end
    end

    json ret: "success"
  else
    json ret: "error", msg: user.info.errors.messages.inspect
  end
end

get '/user/profile' do
  redirect to('/login?r=' + CGI.escape('/user/profile')) unless login?

  unless @user = User.find_by(id: session[:user_id])
    return (json ret: "error", msg: "account_error")
  end

  @title = "我的资料"
  @user_info = @user.info
  @is_newbie = (@user.status == User::NEWBIE)
  erb :own_profile
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
