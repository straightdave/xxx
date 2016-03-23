get '/admin/job' do
  @title = "工作岗位管理"
  @navbar_active = "job"
  erb 'admin/job_manage'.to_sym, layout: 'admin/layout'.to_sym
end
