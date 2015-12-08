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
  salty_password = add_salt(password, salt)

  new_login = User.new
  new_login.login_name = login_name
  new_login.password = salty_password
  new_login.salt = salt

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

post '/login' do
  login_name = params['login_name']
  password = params['password']

  user = User.find_by(login_name: login_name)
  if user && user.password == add_salt(password, user.salt)
    login_user user
    json ret: "success"
  else
    json ret: "error", msg: "user_not_found|passwd_error"
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
