# ===== user registering =====
get '/user/signup' do
  @title = "用户注册"
  @navbar_hide_level = 'all'
  erb :user_signup
end

post '/user/check_name/:login_name' do |login_name|
  if User.exists?(login_name: login_name.downcase)
    json ret: "error", msg: "name_exist"
  else
    json ret: "success"
  end
end

post '/user/check_email/:email' do |email|
  if User.exists?(email: email.downcase)
    json ret: "error", msg: "email_exist"
  else
    json ret: "success"
  end
end

post '/user/signup' do
  login_name = ERB::Util.h params['login_name']
  email      = ERB::Util.h params['email']
  password   = ERB::Util.h params['password']
  nickname   = ERB::Util.h params['nickname']

  login_name.downcase! if login_name
  email.downcase! if email

  if session[:captcha_result] != 'ok'
    return json ret: "error", msg: "captcha_failed"
  end

  if User.exists?(login_name: login_name)
    return json ret: "error", msg: "name_exist"
  end

  if User.exists?(email: email)
    return json ret: "error", msg: "email_exist"
  end

  new_user = User.new
  new_user.login_name = login_name
  new_user.status     = User::Status::NEWBIE
  new_user.email      = email
  new_user.set_password(password)
  new_user.gen_and_set_new_vcode
  new_user.reputation = 1
  new_user.build_info( nickname: (nickname.empty? ? login_name : nickname) )

  if new_user.valid?
    new_user.generate_avatar(settings.avatar_folder)
    new_user.save
    send_welcome_message new_user
    send_validation_mail new_user
    log_out if login?
    log_in new_user
    json ret: "success", msg: new_user.id
  else
    json ret: "error", msg: "model_invalid"
  end
end

# validation here can be used not only for signing up process,
# but also for reseting user status and other check/confirmation by sending mail
# after all, the thing to be validated is the user email
get '/user/validation' do
  user_id         = ERB::Util.h params['id']
  validating_code = ERB::Util.h params['code']
  backdoor        = ERB::Util.h params['backdoor']    # TODO remove this. only for dev

  if user_id.nil? || validating_code.nil?
    validated = false
  else
    validated = (User.validate(user_id, validating_code) == :ok)
  end

  validated = true if backdoor == "true"

  if validated
    redirect to('/notice?reason=validok')
  else
    redirect to('/notice?reason=validfailed')
  end
end

post '/user/send_validation' do
  if (last_sent_time = session[:last_sent_time]) &&
     (Time.now.to_i - last_sent_time.to_i < 10)
    return json ret: "error", msg: "resend_too_frequent"
  end

  unless user = User.find_by(id: session[:user_id])
    return json ret: "error", msg: "invalid_user"
  end

  session[:last_sent_time] = Time.now.to_i
  begin
    user.gen_and_set_new_vcode
    user.save!
    send_validation_mail(user)
    json ret: "success"
  rescue
    json ret: "error", msg: "resend_failed"
  end
end

# === all users list ===
get '/users' do
  if !(@slice = params['slice']) || (@slice.to_i <= 0)
    @slice = 100
  else
    @slice = @slice.to_i
  end

  if !(@page = params['page']) || (@page.to_i <= 0)
    @page = 1
  else
    @page = @page.to_i
  end

  @users = User.where("role <> 8 AND role <> 9")
               .order(reputation: :desc)
               .limit(@slice)
               .offset(@slice * (@page - 1))

  total_users = User.where("role <> 8 OR role <> 9").count
  @total_page = total_users / @slice
  if total_users % @slice != 0
    @total_page += 1
  end

  @title         = "所有用户"
  @navbar_active = "users"
  @breadcrumb = [
    { name: "首页", url: '/' },
    { name: "用户", active: true }
  ]
  erb :user_all
end

# ===== login & logout =====
get '/user/signin' do
  log_out
  @title = "用户登录"
  @navbar_hide_level = 'all'
  erb :user_signin
end

post '/user/signin' do
  if session[:delay_start] && session[:delay_duration]
    start_delay_sec = session[:delay_start].to_i
    delay_duration  = session[:delay_duration].to_i
    now_sec = Time.now.to_i
    if now_sec - start_delay_sec > delay_duration
      session[:delay_start]    = nil
      session[:delay_duration] = nil
    else
      return json ret: "error", msg: "waiting"
    end
  end

  try_count = session[:try_count] || 0
  if try_count > 5 && try_count <= 10
    session[:try_count]      = try_count + 1
    session[:delay_start]    = Time.now.to_i
    session[:delay_duration] = 15
    return json ret: "error", msg: "fail_5"
  elsif try_count > 10
    session[:try_count]      = nil
    session[:delay_start]    = Time.now.to_i
    session[:delay_duration] = 30
    return json ret: "error", msg: "fail_10"
  else
    session[:try_count] = try_count + 1
  end

  login_name = ERB::Util.h params['login_name']
  password   = ERB::Util.h params['password']

  login_name.downcase! if login_name

  user = User.find_by(login_name: login_name)
  if user && user.authenticate(password)
    log_out if login?
    log_in user
    session[:try_count]      = nil
    session[:delay_start]    = nil
    session[:delay_duration] = nil
    json ret: "success"
  else
    json ret: "error", msg: "login_fail"
  end
end

get '/logout' do
  log_out
  redirect to("/")
end

get '/check_login' do
  (login?) ? (json ret: true) : (json ret: false)
end

# get current user
get '/user' do
  if @_current_user
    user_info    = @_current_user.info
    data = {
      "id"           => @_current_user.id,
      "url"          => @_current_user.url,
      "name"         => @_current_user.login_name,
      "display"      => user_info.nickname,
      "avatar"       => @_current_user.avatar_src,
      "reputation"   => @_current_user.reputation,
      "created_at"   => @_current_user.created_at
    }
    json ret: true, msg: data.to_json
  else
    json ret: false
  end
end

get '/user/unread' do
  number = params["n"] || 5
  if @_current_user
    msg_to_show = @_current_user.inbox_messages.where(isread: false).take(number)
    data = {
      "unread_msg"   => msg_to_show.to_json
    }
    json ret: true, msg: data.to_json
  else
    json ret: false
  end
end

# === password refinding ===
get '/user/iforgot' do
  @name  = params["u"]
  @name.downcase! if @name
  @title = "找回密码"
  erb :iforgot
end

post '/user/iforgot' do
  if (name = ERB::Util.h(params['name'])) && (user = User.find_by(login_name: name.downcase))

    unless email = (ERB::Util.h params['email'])
      return json ret: "error", msg: "请输入邮箱"
    end

    if user.email == email.downcase
      user.gen_and_set_new_vcode
      user.save!
      send_refind_mail user
      json ret: "success"
    else
      json ret: "error", msg: "邮箱和用户名不匹配"
    end

  else
    json ret: "error", msg: "请输入注册名称或名称不存在"
  end
end

# reset password page
get '/user/reset_password' do
  id   = ERB::Util.h params['id']
  code = ERB::Util.h params['code']

  if id.nil? || code.nil?
    return "no id and vcode"
  end

  if !!User.check_reset_request(id, code)
    # validate OK, show page
    session[:user_id] = id
    @title = "重设密码"
    erb :reset_password
  else
    # reset request not valid, show error page
    "We think this is an invalid request."
  end
end

# reset new password
post '/user/reset_password' do
  pass1 = ERB::Util.h params['pass1']
  pass2 = ERB::Util.h params['pass2']

  unless id = session[:user_id]
    return json ret: "error", msg: "用户id错误"
  end

  unless user = User.find_by(id: id)
    return json ret: "error", msg: "用户对象错误"
  end

  if pass1.nil? || pass2.nil?
    return json ret: "error", msg: "输入的密码为空"
  end

  if pass1 == pass2
    user.reset_password(pass1)
    if user.valid?
      user.save
      json ret: "success"
    else
      json ret: "error", msg: "密码重设失败"
    end
  else
    json ret: "error", msg: "两次输入密码不一致"
  end
end
