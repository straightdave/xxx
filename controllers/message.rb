# === actions of insite messages ===
get '/user/messages' do
  login_filter
  user = User.find_by(id: session[:user_id])

  if !(@slice = params['slice']) || (@slice.to_i <= 0)
    @slice = 50
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
  erb :my_messages
end

# ajax invoke for number of messages
post '/user/message_amount' do
  login_filter
  user = User.find_by(id: session[:user_id])

  json ret: "success", msg: user.inbox_messages.length
end

# mark all as read
post '/user/mark_messages' do
  login_filter
  user = User.find_by(id: session[:user_id])

  begin
    user.inbox_messages.where(isread: false).each { |m| m.isread = 1; m.save }
    session[:message_amount] = 0
    json ret: "success"
  rescue
    json ret: "error", msg: user.errors.messages.inspect
  end
end
