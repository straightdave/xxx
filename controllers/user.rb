# ===== user registering =====
get '/user/signup' do
  log_out if login?
  @title = "用户注册"
  erb :user_signup
end

post '/user/check_name/:login_name' do |login_name|
  if User.exists?(login_name: login_name)
    json ret: "error", msg: "name_exist"
  else
    json ret: "success"
  end
end

post '/user/check_email/:email' do |email|
  if User.exists?(email: email)
    json ret: "error", msg: "email_exist"
  else
    json ret: "success"
  end
end

post '/user/signup' do
  login_name = params['login_name']
  email      = params['email']
  password   = params['password']
  nickname   = params['nickname']

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
  new_user.build_info( nickname: (nickname.empty? ? login_name : nickname) )

  if new_user.valid?
    new_user.save
    send_welcome_message new_user
    send_validation_mail new_user
    log_in new_user
    json ret: "success", msg: new_user.id
  else
    json ret: "error", msg: "model_invalid"
  end
end

get '/user/validation' do
  id = params['id']
  code = params['code']
  @validated = !! User.validate(id, code)
  @title = "验证结果"
  erb :validation_result
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

# === users list ===
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

  @users = User.order(reputation: :desc)
               .limit(@slice).offset(@slice * (@page - 1))

  total_users = User.count
  @total_page = total_users / @slice
  if total_users % @slice != 0
    @total_page += 1
  end

  @title         = "所有用户"
  @navbar_active = "users"
  erb :user_all
end

# ===== login & logout =====
get '/login' do
  log_out if login?
  @name        = params['u']
  @title       = "用户登录"
  @return_page = params['r']
  words_flag   = params['w'].to_i

  @words_on_login_page = case words_flag
  when 1 then "请先登录"
  when 2 then "请登录管理员"
  when 3 then "好像账户有问题啊，请重新登录试试？"
  when 4 then "权限和状态有问题啊，请重新登录试试？"
  else nil
  end

  erb :login
end

post '/login' do
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

  login_name = params['login_name']
  password   = params['password']

  user = User.find_by(login_name: login_name)
  if user && user.authenticate(password)
    log_in user
    session[:try_count]      = nil
    session[:delay_start]    = nil
    session[:delay_duration] = nil
    json ret: "success"
  else
    json ret: "error", msg: "login_fail"
  end
end

post '/logout' do
  log_out
  json ret: "success"
end

get '/check_login' do
  (login?) ? (json ret: true) : (json ret: false)
end

# === password refinding ===
get '/user/iforgot' do
  @name  = params["u"]
  @title = "找回密码"
  erb :iforgot
end

post '/user/iforgot' do
  if (name = params['name']) && (user = User.find_by(login_name: name))

    unless email = params['email']
      return json ret: "error", msg: "请输入邮箱"
    end

    if user.email == email
      user.gen_and_set_new_vcode
      user.save!
      send_refind_mail user
      json ret: "success"
    else
      json ret: "error", msg: "邮箱和用户名不匹配"
    end

  else
    return json ret: "error", msg: "请输入注册名称或名称不存在"
  end
end

# reset password page
get '/user/reset_password' do
  id   = params['id']
  code = params['code']

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
  pass1 = params['pass1']
  pass2 = params['pass2']

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
