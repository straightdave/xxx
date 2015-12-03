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


# ====== user profile actions ======
# update own profile
post '/user/profile' do
  unless user = User.find_by(id: session[:user_id])
    return (json ret: "error", msg: "need_login|account_error")
  end

  user.info.nickname = params['nickname']
  user.info.email = params['email']
  user.info.intro = params['intro']

  if user.info.valid?
    user.info.save
    json ret: "success"
  else
    json ret: "error", msg: user.info.errors.messages.inspect
  end
end

# view one's own profile
get '/user/profile' do
  redirect to("/login?returnurl=#{request.url}") unless login?

  unless @user = User.find_by(id: session[:user_id])
    return (json ret: "error", msg: "account_error")
  end

  @title = "你的资料"
  erb :own_profile
end

# view other's profile
get '/u/:name' do |name|
  unless user = User.find_by(login_name: name)
    return (erb :page_404, layout: false)
  end

  @user_info = user.info
  @title = user.info.nickname
  erb :user_profile
end
