get '/feedback' do
  login_filter

  @title = "用户反馈"
  erb :feedback
end

post '/feedback' do
  author = login_filter

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
