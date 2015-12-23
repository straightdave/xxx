# === actions of insite messages ===
get '/user/messages' do
  unless user = User.find_by(id: session[:user_id])
    return json ret: "error", msg: "need_login"
  end
  @title = "收件箱"
  @messages = user.inbox_messages
  @breadcrumb = [
    { name: "首页", url: '/' },
    { name: "收件箱", active: true }
  ]
  erb :my_messages
end

# ajax invoke for number of messages
post '/user/message_amount' do
  unless user = User.find_by(id: session[:user_id])
    return json ret: "error", msg: "need_login"
  end
  json ret: "success", msg: user.inbox_messages.length
end

# mark all as read
post '/user/mark_messages' do
  unless user = User.find_by(id: session[:user_id])
    return json ret: "error", msg: "need_login"
  end

  begin
    user.inbox_messages.where(isread: false).each { |m| m.isread = 1; m.save }
    session[:message_amount] = 0
    json ret: "success"
  rescue
    json ret: "error", msg: user.errors.messages.inspect
  end
end
