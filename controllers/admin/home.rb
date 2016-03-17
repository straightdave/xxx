get '/admin/home' do
  @title = "管理员页面"
  @navbar_active = "home"
  erb 'admin/home'.to_sym, layout: 'admin/layout'.to_sym
end

get '/admin/help' do
  @title = "管理员页面"
  erb 'admin/help'.to_sym, layout: 'admin/layout'.to_sym
end

get '/admin/?' do
  redirect to('/admin/home')
end
