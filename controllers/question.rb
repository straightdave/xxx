get '/ask' do
  return (json ret: "error", msg: "need_login") unless login?
  @title = "提问"
  @breadcrumb = [
    {name: "首页", url: '/'},
    {name: "提问", active: true}
  ]
  erb :ask
end

post '/ask' do
  return (json ret: "error", msg: "need_login") unless login?

  author = User.find_by(id: session[:user_id])

  new_q = Question.new
  new_q.title = params['title']
  new_q.content = params['content']
  new_q.author = author
  new_q.watchers << author # add to author's watching list by default
  new_q.last_doer = author
  new_q.last_do_type = 0 # 0 means asking
  new_q.last_do_at = Time.now

  params['tags'].split(',').each do |t|
    tag = Tag.find_or_create_by(name: t)
    tag.used += 1
    new_q.tags << tag
    tag.save if tag.valid?
  end

  unless new_q.valid?
    return (json ret: "error", msg: new_q.errors.messages.inspect)
  end
  new_q.save
  set_just_viewed(new_q.id)
  send_msg_after_ask(author, new_q)

  HistoricalAction.create(
    user_id: session[:user_id],
    action_type: 'q',
    target_type: 'q',
    target_id: new_q.id,
    created_at: Time.now
  )

  json ret: "success", msg: new_q.id
end


# == display a question ==
get '/q/:qid' do |qid|
  if @q = Question.find_by(id: qid)
    unless just_viewed_this?(qid)
      @q.views += 1
      @q.save
      set_just_viewed(qid)
    end
    @hidden_edit = @q.author.id != session[:user_id]
    @watched = @q.watchers.exists?(id: session[:user_id])
    @answered = !@q.accepted_answer.nil?
    @title = @q.title[0..10] + "..."
    @breadcrumb = [
      {name: "问答", url: '/'},
      {name: "问题详情", active: true}
    ]
    erb :question
  else
    halt 404, (erb :msg_page, locals: {
                              title: "404 Not Found",
                              body: "找不到您请求的资源"
                              })
  end
end


# == watching or unwatching a question ==
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


post '/q/:qid/unwatch' do |qid|
  return (json ret: "error", msg: "need_login") unless login?

  if q = Question.find_by(id: qid)
    if author = User.find_by(id: session[:user_id])
      q.watchers.delete(author)
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
    if q.author.id != session[:user_id]
      if author = User.find_by(id: session[:user_id])
        content = params['content']
        answer = Answer.new
        answer.author = author
        answer.question = q
        answer.content = content
        q.watchers << author
        q.last_doer = author
        q.last_do_type = 1 # 0 means answering
        q.last_do_at = Time.now

        if answer.valid? && q.valid?
          answer.save
          q.save
          send_msg_after_answer(q, author)

          HistoricalAction.create(
            user_id: session[:user_id],
            action_type: 'a',
            target_type: 'q',
            target_id: q.id,
            created_at: Time.now
          )

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
