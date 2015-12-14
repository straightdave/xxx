# ===== user registering actions =====
get '/user/register' do
  @title = "用户注册"
  erb :user_register unless login?
end

post '/user/register' do
  login_name = params['login_name']
  password = params['password']
  password_again = params['password_again']
  is_confirmed = params['confirmed']

  if User.exists?(login_name: login_name)
    return (json ret: "error", msg: "name_exist")
  end

  if password_again != password || !is_confirmed
    return (json ret: "error", msg: "login_info_err")
  end

  salt = Time.now.hash.to_s[-5..-1] # here generating a random salt

  new_login = User.new
  new_login.login_name = login_name
  new_login.set_password_and_salt(password, salt)

  # build user info with default nickname => login name
  new_login.build_info(nickname: login_name)

  if new_login.valid?
    new_login.save
    # login_user should invoke after message-sent
    # to store msg amount in session
    send_welcome_message new_login
    login_user new_login
    json ret: "success", msg: new_login.id
  else
    json ret: "error", msg: new_login.errors.messages.inspect
  end
end

# ===== login & logout actions =====
get '/login' do
  @title = "登录"
  erb :login unless login?
end

# login with delay logic
post '/login' do
  if session[:delay_start] && session[:delay_duration]
    start_delay_sec = session[:delay_start].to_i
    delay_duration = session[:delay_duration].to_i
    now_sec = Time.now.to_i
    if now_sec - start_delay_sec > delay_duration
      # goto normal process
      session[:delay_start] = nil
      session[:delay_duration] = nil
    else
      return (json ret: "error", msg: "waiting")
    end
  end

  try_count = session[:try_count] || 0
  if try_count > 5 && try_count <= 10
    session[:delay_start] = Time.now.to_i
    session[:delay_duration] = 15
    session[:try_count] = try_count + 1
    return (json ret: "error", msg: "fail_5")
  elsif try_count > 10
    session[:delay_start] = Time.now.to_i
    session[:delay_duration] = 30
    session[:try_count] = nil
    return (json ret: "error", msg: "fail_10")
  else
    session[:try_count] = try_count + 1
  end

  login_name = params['login_name']
  password = params['password']

  user = User.find_by(login_name: login_name)
  if user && user.authenticate(password)
    login_user user
    session[:try_count] = nil
    session[:delay_start] = nil
    session[:delay_duration] = nil
    json ret: "success"
  else
    json ret: "error", msg: "login_fail"
  end
end

post '/logout' do
  logout_user
  json ret: "success"
end

get '/check_login' do
  (login?) ? (json ret: true) : (json ret: false)
end


# === user forgot password ===
get '/user/iforgot' do
  @name = params["u"]
  @title = "找回密码"
  erb :iforgot
end

post '/user/iforgot' do
  json ret: "success"
end
