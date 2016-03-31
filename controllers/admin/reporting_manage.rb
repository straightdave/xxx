get '/admin/reporting' do
  @title = "投诉管理"
  @navbar_active = "re"

  erb 'admin/reporting_manage'.to_sym, layout: 'admin/layout'.to_sym
end
