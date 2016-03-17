get '/admin/account' do
  login_name = params['qn']
  @user = User.find_by(login_name: login_name)
  @title = "账户管理"
  @navbar_active = "acc"
  erb 'admin/account_manage'.to_sym, layout: 'admin/layout'.to_sym
end

post '/admin/account/:uid/reset_report' do |uid|
  user = User.find_by(id: uid)
  user.is_reported = false
  user.save if user.valid?
  redirect to("/admin/account?qn=#{user.login_name}")
end

post '/admin/account/:uid' do |uid|
  user = User.find_by(id: uid)
  user.role   = params['user-role']
  user.status = params['user-status']
  user.save if user.valid?
  redirect to("/admin/account?qn=#{user.login_name}")
end
