# handle users' feedbacks behaviors
get '/feedback' do
  redirect to('/login?r=' + CGI.escape('/feedback')) unless login?
  @title = "用户反馈"
  erb :feedback
end

post '/feedback' do
  return (json ret: "error", msg: "需要登录") unless login?

  author = User.find_by(id: session[:user_id])
  return (json ret: "error", msg: "账户异常") unless author
  return (json ret: "error", msg: "账户状态非法") if author.status != User::NORMAL

  # interface to front-end:
  # title - string
  # desc - string
  feedback = Feedback.new
  feedback.user_id     = author.id
  feedback.title       = params['title']
  feedback.description = params['desc']

  if feedback.valid?
    feedback.save
    json ret: "success"
  else

    json ret: "error", msg: "创建反馈失败"
  end
end
