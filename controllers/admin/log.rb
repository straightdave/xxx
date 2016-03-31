get '/admin/log' do
  @title         = "管理日志"
  @navbar_active = "log"

  # filtered by admin name
  if (@login_name = params['qn']) && (@user = User.find_by(login_name: @login_name))
    logs = AdminLog.where(user_id: @user.id)
  else
    logs = AdminLog.all
  end

  # filtered by time span
  @start_at = params['start_at'] || ""
  @end_at   = params['end_at'] || ""
  if @start_at && @end_at.empty?
    logs = logs.where("created_at >= :start_date", { start_date: @start_at })
  elsif @start_at.empty? && @end_at
    logs = logs.where("created_at <= :end_date", { end_date: @end_at })
  elsif @start_at && @end_at
    logs = logs.where("created_at >= :start_date AND created_at <= :end_date",
                      { start_date: @start_at, end_date: @end_at })
  end

  # paging - full
  @page  = params['page'].to_i  || 1
  @slice = params['slice'].to_i || 50
  @page  = 1  if @page <= 0
  @slice = 50 if @slice < 1

  @total_page = (logs.count / @slice) + (logs.count % @slice != 0 ? 1 : 0)
  @logs = logs.order(created_at: :desc).limit(@slice).offset(@slice * (@page - 1))

  erb 'admin/log_page'.to_sym, layout: 'admin/layout'.to_sym
end
