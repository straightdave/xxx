# === actions of insite messages ===
get '/user/messages' do
  # not require any status (which is normal as default)
  user = login_filter required_status: false

  if !(@slice = params['slice']) || (@slice.to_i <= 0)
    @slice = 20
  else
    @slice = @slice.to_i
  end

  if !(@page = params['page']) || (@page.to_i <= 0)
    @page = 1
  else
    @page = @page.to_i
  end

  @messages = user.inbox_messages
                  .order(sent_at: :desc)
                  .limit(@slice)
                  .offset(@slice * (@page - 1))

  total_messages = @messages.count
  @total_page = total_messages / @slice
  @total_page += 1 if total_messages % @slice != 0

  @title = "收件箱"
  @breadcrumb = [
    { name: "首页", url: '/' },
    { name: "收件箱", active: true }
  ]
  erb :user_messages
end

# ajax invoke for number of messages
post '/user/message_amount' do
  user = login_filter required_status: false
  json ret: "success", msg: user.inbox_messages.where(isread: false).length
end

# mark all as read
post '/user/mark_messages' do
  user = login_filter required_status: false
  begin
    user.inbox_messages.where(isread: false).each { |m| m.isread = 1; m.save }
    session[:message_amount] = 0
    json ret: "success"
  rescue
    json ret: "error", msg: user.errors.messages.inspect
  end
end
