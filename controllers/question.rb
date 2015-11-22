get '/ask' do
  if login?
    erb :ask
  else
    json ret: "error", msg: "need_login"
  end
end

post '/ask' do
  return (json ret: "error", msg: "need_login") unless login?

  author = User.find_by(user_id: session[:user_id])

  new_q = Question.new
  new_q.title = params['title']
  new_q.content = params['content']
  new_q.asker = author
  new_q.watchers << author
  puts new_q.watchers.inspect

  new_q.last_doer = author
  new_q.last_do_type = 0 # 0 means asking
  new_q.last_do_at = Time.now

  params['tags'].split(',').each do |t|
    new_q.tags << (Tag.find_by(name: t) || Tag.create(name: t))
  end

  if new_q.valid?
    qid = new_q.save
    cookies[:just_viewed] = qid.to_s
    json ret: "success", msg: { qid: qid }
  else
    json ret: "error", msg: new_q.errors.messages.inspect
  end
end

get '/q/:qid' do |qid|
  if @q = Question.find_by(id: qid)
    if login? && cookies[:just_viewed] != qid
      @q.views += 1
      @q.save
      cookies[:just_viewed] = qid
    end
    erb :question
  else
    halt 404, (erb :msg_page, locals: { title: "404 Not Found", body: "找不到您请求的资源" })
  end
end


# == voting ==
# need different reputation to do such two operations
post '/q/:qid/vote' do |qid|
  points = params['op'] || "add"
  if q = Question.find_by(id: qid)
    if login? && cookies[:just_voted] != qid
      q.votes += 1
      q.save
      cookies[:just_voted] = qid
    end
  else
    json ret: "error", msg: "question_not_found"
  end
end

post '/q/:qid/vote' do |qid|
  points = params['op'] || "add"
  if q = Question.find_by(id: qid)
    if login? && cookies[:just_voted] != qid
      q.votes += 1
      q.save
      cookies[:just_voted] = qid
    end
  else
    json ret: "error", msg: "question_not_found"
  end
end
