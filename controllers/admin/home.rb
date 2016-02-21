get '/admin' do
  @user ||= User.find_by(login_name: session[:login_name])
  if @user && @user.admin?
    @title = "管理员页面"
    @navbar_active = "admin_home"
    erb 'admin/home'.to_sym, layout: 'admin/layout'.to_sym
  else
    redirect to('/login?r=' + CGI.escape('/admin') + '&w=2')
  end
end

get '/admin/help' do
  @title = "管理员页面"
  erb 'admin/help'.to_sym, layout: 'admin/layout'.to_sym
end
