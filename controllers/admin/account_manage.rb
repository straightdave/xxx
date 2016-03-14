get '/admin/accounts' do
  @title = "账户管理"
  @navbar_active = "account_manage"
  erb 'admin/account_manage'.to_sym, layout: 'admin/layout'.to_sym
end

# for ajax invoke
get '/admin/user/:login_name' do |login_name|
  if user = User.find_by(login_name: login_name)
    json user
  else
    json ret: "not_found"
  end
end
