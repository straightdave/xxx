get '/ask' do
  return (json ret: "error", msg: "need_login") unless login?

  @title = "提问"
  erb :ask
end

post '/ask' do
  return (json ret: "error", msg: "need_login") unless login?

  author = User.find_by(id: session[:user_id])

  new_q = Question.new
  new_q.title = params['title']
  new_q.content = params['content']
  new_q.asker = author
  new_q.watchers << author # add to asker's watching list by default

  new_q.last_doer = author
  new_q.last_do_type = 0 # 0 means asking
  new_q.last_do_at = Time.now

  params['tags'].split(',').each do |t|
    new_q.tags << (Tag.find_by(name: t) || Tag.create(name: t))
  end

  unless new_q.valid?
    return (json ret: "error", msg: new_q.errors.messages.inspect)
  end

  new_q.save
  set_just_viewed(qid)
  json ret: "success", msg: new_q.id
end


# == display a question ==
get '/q/:qid' do |qid|
  if @q = Question.find_by(id: qid)
    if login? && !just_viewed_this?(qid)
      @q.views += 1
      @q.save
      set_just_viewed(qid)
    end
    @hidden_edit = @q.asker.id != session[:user_id]
    @watched = @q.watchers.exists?(id: session[:user_id])
    @title = @q.title[0..10] + "..."
    erb :question
  else
    halt 404, (erb :msg_page, locals: {
                title: "404 Not Found",
                body: "找不到您请求的资源"
              })
  end
end


# == watching a question ==
post '/q/:qid/watch' do |qid|
  return (json ret: "error", msg: "need_login") unless login?

  if q = Question.find_by(id: qid)
    if author = User.find_by(id: session[:user_id])
      q.watchers << author

      if q.valid?
        q.save
        json ret: "success"
      else
        json ret: "error", msg: q.errors.messages
      end
    else
      json ret: "error", msg: "user_not_found"
    end
  else
    json ret: "error", msg: "question_not_found"
  end
end


# == answering ==
post '/q/:qid/answer' do |qid|
  return (json ret: "error", msg: "need_login") unless login?

  if q = Question.find_by(id: qid)
    if q.asker.id != session[:user_id]
      if author = User.find_by(id: session[:user_id])
        content = params['content']
        answer = Answer.new
        answer.author = author
        answer.question = q
        answer.content = content
        q.watchers << author

        if answer.valid? && q.valid?
          answer.save
          q.save
          json ret: "success", msg: answer.id
        else
          json ret: "error", msg: "a:" + answer.errors.messages.inspect +
                                  ";q:" + q.errors.messages.inspect
        end
      else
        json ret: "error", msg: "user_not_found"
      end
    else
      json ret: "error", msg: "self_answer"
    end
  else
    json ret: "error", msg: "question_not_found"
  end
end
