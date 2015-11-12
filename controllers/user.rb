# user register action call (get), render register page
get '/register' do
  erb :register, layout: :basic_layout unless login?
end

# post action for register user
# after valid info saved, redirect to post-register page which shows
# email-validation links
post '/register' do
  login_email = params['login_email']
  passwd_before_salt = params['password']

  salt = "StUpIdAsS" # here goes a random salt
  salty_passwd = add_salt(passwd_before_salt, salt)

  new_login = UserLogin.new
  new_login.login_email = login_email
  new_login.passwd = salty_passwd
  new_login.salt = salt
  new_login.last_login_at = Time.now
  new_login.last_login_ip = request.ip

  if new_login.valid?
    new_login.save

    if settings.enable_mailing_activate?
      send_activate_mail(login_email)
      redirect to("/after_register?id=#{new_login.id}")
    else
      # 0 - just registered; - default
      # 1 - activated; normal;
      # 2 - disabled; banned;
      # 3 - removed;
      new_login.status = 1
      new_login.save
      redirect to("/after_activate?id=#{new_login.id}")
    end

    session[:login_email] = login_email
    session[:user_id] = new_login.user_id
  else
    # TODO
    "register failed!"
  end
end

# after_*** action, rendering post-*** page
# mainly they are showing messages to users
get %r{/after_([\w]+)} do |c|
  @id = params['id']

  if c == 'register'
    erb :after_register, layout: :basic_layout
  elsif c == 'activate'
    erb :after_activate, layout: :basic_layout
  end
end

# get action for activate user
# mostly it is called from mail links
get '/activate' do
  "activated! (a lie)"
end

# action for authentication, u&p passed backward by js
post '/login' do
  login_email = params['login_email']
  passwd = params['password']

  user = UserLogin.find_by(login_email: login_email)
  if user and user.passwd == add_salt(passwd, user.salt)
    user.last_login_at = Time.now
    user.last_login_ip = request.ip
    user.save

    session[:login_email] = login_email
    session[:user_id] = user.user_id
    '{"result":"success"}'
  else
    '{"result":"fail"}'
  end
end

# simple logout action
post '/logout' do
  session[:login_email] = nil
  session[:user_id] = nil
end

# ====== user profile actions ======

# update user profile
post '/user/:id/update' do |id|
  user = UserLogin.find_by(user_id: id)
  is_oneself = user && session[:login_email] == user.login_email

  if is_oneself
    user_info = user.userinfo
    user_info.nickname = params['nickname']
    user_info.email = params['email']
    user_info.intro = params['intro']

    if user_info.valid?
      user_info.save
      redirect to("/user/#{id}")
    else
      # TODO
      "update failed"
    end
  else
    # TODO
    "you need to login as this user."
  end
end

# view user profile
get '/user/:id' do |id|
  user = UserLogin.find_by(user_id: id)
  if user
    @id = id
    @user_info = user.userinfo
    @is_oneself = session[:login_email] == user.login_email
    erb :user_profile, layout: :basic_layout
  else
    # TODO
    "User not found"
  end
end
