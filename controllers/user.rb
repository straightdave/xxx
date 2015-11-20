# ===== register related actions =====
get '/register' do
  erb :register unless login?
end

post '/register' do
  login_email = params['u']
  passwd_before_salt = params['p1']
  passwd_again = params['p2']
  is_confirmed = params['c']

  if User.find_by(login_email: login_email)
    return (json ret: "error", msg: "email_exist")
  end

  if passwd_again != passwd_before_salt || !is_confirmed
    return (json ret: "error", msg: "login_info_err")
  end

  salt = "StUpIdAsS" # here goes a random salt
  salty_passwd = add_salt(passwd_before_salt, salt)

  new_login = User.new
  new_login.login_email = login_email
  new_login.passwd = salty_passwd
  new_login.salt = salt

  if new_login.valid?
    new_login.save

    if settings.enable_mailing_activate?
      send_activate_mail(login_email)
      return (json ret: "success", msg: "mail_confirm")
    else
      # 0 - just registered; - default
      # 1 - activated; normal;
      # 2 - disabled; banned;
      # 3 - removed;
      new_login.status = 1
    end

    login_user new_login
    json ret: "success", msg: "done"
  else
    json ret: "error", msg: "login_info_err"
  end
end

get '/after_register' do
  erb :msg_page, locals: {}
end

get '/mail_confirm' do
  erb :msg_page, locals: {}
end


# ===== login & logout actions =====
get '/login' do
  if login?
    redirect to("/")
  else
    erb :login
  end
end

post '/login' do
  login_email = params['login_email']
  passwd = params['password']

  user = User.find_by(login_email: login_email)
  if user && user.passwd == add_salt(passwd, user.salt)
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
  if login?
    json ret: true
  else
    json ret: false
  end
end


# ====== user profile actions ======
post '/user/:id/update' do |id|
  user = User.find_by(user_id: id)
  is_oneself = user && session[:login_email] == user.login_email

  if is_oneself
    user_info = user.userinfo
    user_info.nickname = params['nickname']
    user_info.email = params['email']
    user_info.intro = params['intro']

    if user_info.valid?
      user_info.save
      json ret: "success"
    else
      json ret: "error", msg: "invalid_user_info"
    end
  else
    json ret: "error", msg: "authentication_error"
  end
end

get '/user/:id/update' do | id|
  if id == session[:user_id].to_s
    erb :user_profile_new
  else
    erb :msg_page, locals: { title: "无效的请求", body: "您无法修改该用户的信息，这可能是由于您未登录引起的。" }
  end
end

get '/user/:id' do |id|
  if user = User.find_by(user_id: id)
    if session[:login_email] == user.login_email
      if @user_info = user.userinfo
        erb :user_profile
      else
        quick_url = "/user/#{id}/update"
        erb :msg_page,
            locals: {
              title: "请完善您的信息",
              body: "<a href='#{ url(quick_url) }'>传送门</a>"
            }
      end
    else
      erb :msg_page, locals: { title: "该用户还没有输入用户信息", body: "lead to new page..." }
    end
  else
    erb :msg_page, locals: { title: "用户未找到", body: "Please check user..." }
  end
end
