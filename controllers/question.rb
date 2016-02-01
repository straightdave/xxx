get '/ask' do
  redirect to('/login?r=' + CGI.escape('/ask')) unless login?
  @title = "提问"
  @navbar_active = "qna"
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
  end unless params['tags'].nil?

  unless new_q.valid?
    return (json ret: "error", msg: new_q.errors.messages.inspect)
  end
  new_q.save
  set_just_viewed(new_q.id)
  send_msg_after_ask(author, new_q)
  author.info.update_reputation(2)
  author.record_event(:ask, new_q)
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

    @watched = @q.watchers.exists?(id: session[:user_id])
    @answered = !@q.accepted_answer.nil?
    @hidden_mark = @q.author.id != session[:user_id] || @answered
    @title = @q.title[0..6] + "..."
    @navbar_active = "qna"
    @page_keywords_list = @q.tags.inject("") {|sum, tag| sum << "#{tag.name} " }
    @page_description = @q.title
    @breadcrumb = [
      {name: "问答", url: '/'},
      {name: "问题详情", active: true}
    ]

    # answers order by score desc, and score must >= -2
    # MENTION! this is how to order/query a virtual attribute of activerecord
    # collection ( use `to_a` )
    @answers = @q.answers
    @answers.select { |answer| answer.scores >= -2 }
    @answers = @answers.to_a.sort { |x, y| y.scores <=> x.scores }

    erb :question
  else
    raise not_found
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
        author.record_event(:watch, q)
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
        author.record_event(:unwatch, q)
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

        # same question answers once by same user
        unless q.answers.where(author: author).empty?
          return json ret: "error", msg: "answer_twice"
        end

        content = params['content']
        answer = Answer.new
        answer.author = author
        answer.question = q
        answer.content = content
        q.watchers << author
        q.last_doer = author
        q.last_do_type = 1    # 1 means answering
        q.last_do_at = Time.now

        if answer.valid? && q.valid?
          answer.save
          q.save
          send_msg_after_answer(q, author)
          author.info.update_reputation(2)
          author.add_expertise(q.tag_ids, :answered_once)
          author.record_event(:answer, answer)
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

# == mark as accepted ==
post '/q/:qid/accept' do |qid|
  return (json ret: "error", msg: "need_login") unless login?
  return (json ret: "error", msg: "no_aid") unless aid = params['aid']

  unless question = Question.find_by(id: qid)
    return json ret: "error", msg: "question_not_found"
  end

  unless answer = question.answers.where(id: aid).take
    return json ret: "error", msg: "answer_not_found"
  end

  unless question.accepted_answer.nil?
    return json ret: "error", msg: "dup_accept"
  end

  question.accepted_answer = answer
  answerer = answer.author

  if question.valid? && answerer.valid?
    question.save && answerer.save
    answerer.info.update_reputation(5)
    answerer.add_expertise(question.tag_ids, :accepted_once)
    question.author.record_event(:accept, answer)
    json ret: "success"
  else
    json ret: "error", msg: "accept_failed"
  end
end
