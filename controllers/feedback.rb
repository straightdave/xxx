# handle users' feedbacks behaviors
get '/feedback' do
  login_filter

  @title = "用户反馈"
  erb :feedback
end

post '/feedback' do
  login_filter

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
