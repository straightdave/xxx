# actions for users operatings, including some helper methods

# simple actions for creating users (register)
get '/userreg' do
  unless login?
    erb :userreg, layout: :basic_layout
  end
end

# post action for reg user
post '/userreg' do
  username = params['username']
  pwd = params['password']

  unless username.empty? or pwd.empty?
    salt = "StUpIdAsS"
    salty_pass = salty_hash(pwd, salt)

    new_login = UserLogin.new
    new_login.login_name = username
    new_login.passwd = salty_pass
    new_login.salt = salt
    new_login.last_login_at = Time.now
    new_login.last_login_ip = request.ip
    new_login.save()

    session[:user] = username
    puts "successfully signed up: user: #{username}"
    redirect to('/')
  end
end

# action for authentication, u&p passed backward by js
post '/userlogin' do
  login_name = params['u']
  passwd = params['p']

  user = UserLogin.find_by(login_name: login_name)
  if user and user.passwd == salty_hash(passwd, user.salt)
    puts "login as user #{login_name}"
    user.last_login_at = Time.now
    user.last_login_ip = request.ip
    session[:user] = login_name
  end
end

# simple logout action
post '/userlogout' do
  session[:user] = nil
end
