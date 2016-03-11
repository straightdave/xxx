get '/admin/home' do
  @user = User.find_by(id: session[:login_id])
  @title = "管理员页面"
  @navbar_active = "admin_home"
  erb 'admin/home'.to_sym, layout: 'admin/layout'.to_sym
end

get '/admin/help' do
  @title = "管理员页面"
  erb 'admin/help'.to_sym, layout: 'admin/layout'.to_sym
end
