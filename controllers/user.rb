# actions for users operatings, including some helper methods

# temp route/page for creating users
# notice: just create an user login, full info is to add later
post '/userreg' do
end

post '/userlogin' do
  login_name = params['u']
  passwd = params['p']
  if login_name == 'user' and passwd == 'abc'
    session[:user] = login_name
  end
end

post '/userlogout' do
  session[:user] = nil
end
