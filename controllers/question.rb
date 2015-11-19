get '/ask' do
  if login?
    erb :ask
  else
    json ret: "error", msg: "need_login"
  end
end

post '/ask' do
  title = params['title']
  tags = params['tags']
  content = params['content']
  user_id = session[:user_id]

  new_q = Question.new
  new_q.title = title
  new_q.content = content
  new_q.user_id = user_id
  new_q.last_doer_id = user_id
  new_q.last_do_at = Time.now

  tag_list = tags.split(',')
  tag_list.each do |t|
    t_obj = Tag.find_by(name: t) || Tag.create(name: t)
    new_q.tags << t_obj
  end

  if new_q.valid?
    new_q.save
    json ret: "success", msg: { qid: new_q.id }
  else
    json ret: "error", msg: new_q.errors.messages
  end
end

get '/q/:qid' do |qid|
  if @q = Question.find_by(id: qid)
    @q.views += 1
    @q.save

    erb :question
  else
    halt 404, (erb :msg_page, locals: { title: "404 Not Found", body: "找不到您请求的资源" })
  end
end
