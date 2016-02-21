get '/admin/accounts' do
  @user ||= User.find_by(login_name: session[:login_name])
  if @user && @user.admin?
    @title = "账户管理"
    @navbar_active = "account_manage"

    @accounts = case @user.role
    when User::Role::SUPERADMIN
      User.where(role: User::Role::ADMIN)
    when User::Role::ADMIN
      User.where("users.role <> #{ User::Role::ADMIN } AND users.role <> #{ User::Role::SUPERADMIN }")
    else []
    end

    erb 'admin/account_manage'.to_sym, layout: 'admin/layout'.to_sym
  else
    redirect to('/login?r=' + CGI.escape('/admin') + '&w=2')
  end
end

# for admin ajax invoke
get '/admin/account/:uid' do |uid|
  user = User.find_by(id: uid)
  json user
end

post '/admin/account/:uid' do |uid|

end
