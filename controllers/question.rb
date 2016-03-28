get '/ask' do
  login_filter

  @title = "提问"
  @navbar_active = "qna"
  @breadcrumb = [
    { name: "首页", url: '/' },
    { name: "提问", active: true }
  ]
  erb :ask
end

post '/ask' do
  login_filter

  author = User.find_by(id: session[:user_id])

  new_q = Question.new
  new_q.title   = params['title']
  new_q.content = params['content']
  new_q.author  = author
  new_q.watchers << author # add to author's watching list by default

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
  author.update_reputation(2)
  author.record_event(:ask, new_q)
  json ret: "success", msg: new_q.id
end

# == questions ==
get '/questions' do
  if !(@sorting = params['sort']) || !(['newest', 'vote', 'active'].include?(@sorting))
    @sorting = 'newest'
  end

  if !(slice = params['slice']) || (slice.to_i <= 0)
    slice = 50
  end

  if !(@page = params['page']) || (@page.to_i <= 0)
    @page = 1
  end

  @questions = Question.all.to_a
  @questions = case @sorting
  when 'vote'
    @questions.sort { |a, b| b.scores <=> a.scores }
  when 'newest'
    @questions.sort { |a, b| b.created_at <=> a.created_at }
  when 'active'
    @questions.sort { |a, b| b.updated_at <=> a.updated_at }
  end

  total_questions = Question.count
  @total_page = total_questions / slice
  if total_questions % slice != 0
    @total_page += 1
  end

  @title         = "所有问题"
  @navbar_active = "qs"
  erb :question_all
end

# == display a question ==
get '/q/:qid' do |qid|
  if @q = Question.find_by(id: qid)
    unless just_viewed_this?(qid)
      @q.views += 1
      @q.save
      set_just_viewed(qid)
    end

    @watched       = @q.watchers.exists?(id: session[:user_id])
    @answered      = !@q.accepted_answer.nil?
    @hidden_mark   = @q.author.id != session[:user_id] || @answered
    @title         = @q.title[0..6] + "..."
    @navbar_active = "qna"
    @page_keywords_list = @q.tags.inject("") {|sum, tag| sum << "#{tag.name} " }
    @page_description   = @q.title
    @breadcrumb = [
      { name: "问答", url: '/' },
      { name: "问题详情", active: true }
    ]

    last_edit_event = @q.get_last_edit_event
    if @is_edited = !last_edit_event.nil?
      @last_editor = last_edit_event.invoker
      @last_edit_time = last_edit_event.created_at
    end

    # answers order by score desc, and score must >= -2
    # MENTION! this is how to order/query a virtual attribute of activerecord
    # collection ( use `to_a` )
    @answers = @q.answers
    @answers.select     { |answer| answer.scores >= -2 }
    @answers.to_a.sort! { |x, y| y.scores <=> x.scores }

    @can_edit = login? &&
                (user = User.find_by(id: session[:user_id])) && (
                (@q.author.id == session[:user_id]) ||
                (user.role == User::Role::MODERATOR) )

    @is_ban_commenting = (@q.status == Question::Status::NOCOMMENT)

    erb :question
  else
    raise not_found
  end
end

# == for ajax: edit ban commenting Status
post '/q/:qid/toggle_comment' do |qid|
  login_filter required_roles: [ User::Role::USER, User::Role::MODERATOR ]

  if question = Question.find_by(id: qid)
    if question.status == 0
      question.status = 1
    elsif question.status == 1
      question.status = 0
    end

    if question.valid?
      question.save
      json ret: "success"
    else
      json ret: "error", msg: "状态修改失败"
    end
  else
    json ret: "error", msg: "找不到此id的问题"
  end
end

# == for ajax: edit content
post '/q/:qid' do |qid|
  login_filter required_roles: [ User::Role::USER, User::Role::MODERATOR ]

  editor = User.find_by(id: session[:user_id])
  if editor.role == User::Role::USER && editor.reputation < 25
    return json ret: "error", msg: "声望超过25才可以修改"
  end

  new_content = params['content']

  if question = Question.find_by(id: qid)
    if editor.role == User::Role::USER && quesiton.is_edited
      return json ret: "error", msg: "已经修改过一次了"
    end

    # TODO: need more sophisticated validation of new content
    old_content = question.content
    if old_content.length > 4 * new_content.length
      return json ret: "error", msg: "暂时规定修改后内容不得少于原文1/4"
    end

    question.content = new_content

    # normal user can only edit once (for now: Mar.28, 2016)
    question.is_edited = true if editor.role == User::Role::USER

    if question.valid?
      question.save
      editor.record_event(:update, question)
      # TODO: editorial history (versions, text changes) should keep in log
      json ret: "success"
    else
      json ret: "error", msg: "问题更新失败"
    end
  else
    json ret: "error", msg: "问题对象未找到"
  end
end


# == watching or unwatching a question ==
post '/q/:qid/watch' do |qid|
  login_filter

  author = User.find_by(id: session[:user_id])

  unless q = Question.find_by(id: qid)
    return json ret: "error", msg: "question_not_found"
  end

  q.watchers << author
  if q.valid?
    q.save
    author.record_event(:watch, q)
    json ret: "success"
  else
    json ret: "error", msg: q.errors.messages
  end
end


post '/q/:qid/unwatch' do |qid|
  login_filter

  author = User.find_by(id: session[:user_id])

  unless q = Question.find_by(id: qid)
    return json ret: "error", msg: "question_not_found"
  end

  q.watchers.delete(author)
  if q.valid?
    q.save
    author.record_event(:unwatch, q)
    json ret: "success"
  else
    json ret: "error", msg: q.errors.messages
  end
end

# == answering ==
post '/q/:qid/answer' do |qid|
  login_filter

  unless q = Question.find_by(id: qid)
    return json ret: "error", msg: "question_not_found"
  end

  author = User.find_by(id: session[:user_id])
  if q.author.id == session[:user_id]
    return json ret: "error", msg: "不可以自己回答自己的问题"
  end

  # same question answers once by same user
  unless q.answers.where(author: author).empty?
    return json ret: "error", msg: "你已经回答过这个问题了"
  end

  content = params['content']
  answer = Answer.new
  answer.author = author
  answer.question = q
  answer.content = content
  q.watchers << author

  if answer.valid? && q.valid?
    answer.save
    q.save
    send_msg_after_answer(q, author)
    author.update_reputation(2)
    author.add_expertise(q.tag_ids, :answered_once)
    author.record_event(:answer, answer)
    json ret: "success", msg: answer.id
  else
    json ret: "error", msg: "a:" + answer.errors.messages.inspect +
                            ";q:" + q.errors.messages.inspect
  end
end

# == mark one answer as accepted one ==
post '/q/:qid/accept' do |qid|
  login_filter

  return (json ret: "error", msg: "no_aid") unless aid = params['aid']

  unless question = Question.find_by(id: qid)
    return json ret: "error", msg: "question_not_found"
  end

  unless question.accepted_answer.nil?
    return json ret: "error", msg: "dup_accept"
  end

  unless answer = question.answers.where(id: aid).take
    return json ret: "error", msg: "answer_not_found"
  end

  question.accepted_answer = answer
  answerer = answer.author

  if question.valid? && answerer.valid?
    question.save && answerer.save
    answerer.update_reputation(5)
    answerer.add_expertise(question.tag_ids, :accepted_once)
    question.author.record_event(:accept, answer)
    json ret: "success"
  else
    json ret: "error", msg: "accept_failed"
  end
end
