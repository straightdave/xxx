get '/admin/account' do
  login_name = params['qn']
  @user = User.find_by(login_name: login_name)

  @title = "账户管理"
  @navbar_active = "account_manage"
  erb 'admin/account_manage'.to_sym, layout: 'admin/layout'.to_sym
end
