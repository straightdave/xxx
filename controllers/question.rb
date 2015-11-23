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
  new_q.watchers << author # add to asker's watching list by default
  puts new_q.watchers.inspect

  new_q.last_doer = author
  new_q.last_do_type = 0 # 0 means asking
  new_q.last_do_at = Time.now

  params['tags'].split(',').each do |t|
    new_q.tags << (Tag.find_by(name: t) || Tag.create(name: t))
  end

  if new_q.valid?
    qid = new_q.save
    set_just_viewed(qid)
    json ret: "success", msg: qid
  else
    json ret: "error", msg: new_q.errors.messages.inspect
  end
end


# == display a question ==
get '/q/:qid' do |qid|
  if @q = Question.find_by(id: qid)
    if login? && !just_viewed_this?(qid)
      @q.views += 1
      @q.save
      set_just_viewed(qid)
    end
    erb :question
  else
    halt 404, (erb :msg_page, locals: { title: "404 Not Found", body: "找不到您请求的资源" })
  end
end


# == voting ==
# TODO
# !! need different reputation to do such two operations
#
post '/q/:qid/vote' do |qid|
  return (json ret: "error", msg: "need_login") unless login?

  if q = Question.find_by(id: qid)
    if u = User.find_by(user_id: session[:user_id])
      if !already_voted?(q)
        vote = Vote.new
        vote.voter = u

        op = params['op'] || "add"
        if op == "add"
          vote.point = 1
        elsif op == "reduce"
          vote.point = -1
        end

        q.votes << vote

        if vote.valid? && q.valid?
          q.save # vote will be autosaved?
          json ret: "success"
        else
          json ret: "error", msg: q.errors.messages.inspect
        end
      else
        json ret: "error", msg: "just_voted"
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
    if q.asker.user_id != session[:user_id]
      if author = User.find_by(user_id: session[:user_id])
        content = params['content']
        answer = Answer.new
        answer.author = author
        answer.question = q
        answer.content = content

        if answer.valid?
          answer.save
          json ret: "success", msg: answer.id
        else
          json ret: "error", msg: answer.errors.messages.inspect
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


# == comment ==
post '/q/:qid/comment' do |qid|
  return (json ret: "error", msg: "need_login") unless login?

  if q = Question.find_by(id: qid)
    if author = User.find_by(user_id: session[:user_id])
      content = params['content']
      c = Comment.new
      c.author = author
      c.content = content
      q.comments << c

      if c.valid? && q.valid?
        q.save    # c will be autosaved?
        json ret: "success", msg: c.id
      else
        json ret: "error", msg: c.errors.messages.inspect
      end
    else
      json ret: "error", msg: "user_not_found"
    end
  else
    json ret: "error", msg: "question_not_found"
  end
end
