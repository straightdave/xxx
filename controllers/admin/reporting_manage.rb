get '/admin/reporting' do
  @title = "投诉管理"
  @navbar_active = "re"

  @reported_users = User.where("has_reports > 0").order(has_reports: :desc).all
  @all_reports    = Report.order(created_at: :desc).all

  erb 'admin/reporting_manage'.to_sym, layout: 'admin/layout'.to_sym
end
