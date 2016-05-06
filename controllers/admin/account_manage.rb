get '/admin/account' do
  if uid = params['uid']
    @user = User.find_by(id: uid)
  end

  if login_name = params['qn']
    @user = User.find_by(login_name: login_name)
  end

  @title = "账户管理"
  @navbar_active = "acc"
  erb 'admin/account_manage'.to_sym, layout: 'admin/layout'.to_sym
end

post '/admin/account/:uid/reset_report' do |uid|
  user = User.find_by(id: uid)
  old_number = user.has_reports
  user.has_reports = 0
  if user.valid?
    user.save
    AdminLog.create(
      :user_id => get_user_id,
      :log_text => "管理员#{get_login_name}重置了用户#{user.login_name}的举报数量 #{old_number} => 0"
    )
  end
  redirect to("/admin/account?qn=#{user.login_name}")
end

post '/admin/account/:uid' do |uid|
  user = User.find_by(id: uid)
  old_status = user.status
  old_role   = user.role
  user.role   = params['user-role']
  user.status = params['user-status']
  if user.valid?
    user.save
    AdminLog.create(
      :user_id => get_user_id,
      :log_text => "管理员#{get_login_name}修改了用户#{user.login_name}的状态(#{old_status}=>#{user.status})，角色(#{old_role}=>#{user.role})"
    )
  end
  redirect to("/admin/account?qn=#{user.login_name}")
end
