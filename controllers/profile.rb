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
