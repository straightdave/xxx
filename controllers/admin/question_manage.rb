get '/admin/question' do
  if qid = params['qid']
    @question = Question.find_by(id: qid)
  end

  @title = "问题管理"
  @navbar_active = "q"
  erb 'admin/question_manage'.to_sym, layout: 'admin/layout'.to_sym
end

post '/admin/question/:qid' do |qid|
  question = Question.find_by(id: qid)
  old_status = question.status
  question.status = params['question-status']
  if question.valid?
    question.save
    AdminLog.create(
      :user_id => get_user_id,
      :log_text => "管理员#{get_login_name}修改了问题 《#{question.title}》的状态(#{old_status}=>#{question.status})"
    )
  end
  redirect to("/admin/question?qid=#{question.id}")
end
