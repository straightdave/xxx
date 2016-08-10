# update user's (own) profile
post '/user/profile' do
  user = login_filter required_status: false, required_roles: false

  email_changed = (user.email != ERB::Util.h(params['email']))
  if email_changed && !user.can_change_email
    return json ret: "error", msg: "当前状态不允许修改主邮箱"
  end

  user.info.nickname = ERB::Util.h params['nickname']
  user.info.intro    = ERB::Util.h params['intro']
  user.info.phone    = ERB::Util.h params['phone']
  user.info.city     = ERB::Util.h params['city']
  user.info.qq       = ERB::Util.h params['qq']
  user.info.wechat   = ERB::Util.h params['wechat']
  user.info.email2   = ERB::Util.h params['email2']
  user.email         = (ERB::Util.h params['email']) if email_changed
  user.info.hideemail = params['hideemail']

  if user.info.valid?
    user.info.save
    user.record_event(:update, user)

    if email_changed && user.can_change_email
      user.status = User::Status::NEWBIE
      user.gen_and_set_new_vcode
      if user.valid?
        user.save
        send_validation_mail user
      else
        return json ret: "error", msg: user.errors.messages.inspect
      end
    end
    json ret: "success"
  else
    json ret: "error", msg: user.info.errors.messages.inspect
  end
end

get '/user/profile' do
  @user = login_filter required_status: false, required_roles: false
  @title = "我的资料"
  @user_info = @user.info

  # set `validated` as `Not equal to NEWBIE` for now
  # TODO: other situation may also need to validate
  @is_validated = (@user.status != User::Status::NEWBIE)
  @navbar_hide_level = 'logo'
  erb :user_update
end

# upload avatar files (maybe any file)
post '/upload' do
  login_filter required_status: false, required_roles: false

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
  full_name = "#{settings.avatar_folder}/#{login_name}.#{ext}"

  File.open(full_name, "w+") do |file|
    file.puts tmpfile.read
  end

  begin
    user_info = UserInfo.find_by(user_id: session[:user_id])
    user_info.avatar = "/uploads/avatars/#{login_name}.#{ext}"
    user_info.save
    json ret: "success", msg: full_name
  rescue
    json ret: "error", msg: $0.inspect
  end

  # for now, redirect to current page
  redirect to("/user/profile")
end
