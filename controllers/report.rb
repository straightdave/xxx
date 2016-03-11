# reporting related actions here
# clicking buttons on pages of targets (users or works)
# modal windows pop-up and input text on it then submit
# all reports will be reviewed by admins

# create a report via ajax
post '/report' do
  login_filter
  reporter = User.find_by(id: session[:user_id])

  # interface to front-end
  # target_type: string, name of reporting target type
  #   'u' -> 'User', 'q' -> 'Question', 'an' -> 'answer', 'ar' -> 'article'
  # target_id: int, reporting target id
  # content: string, content of report
  target_type = params['target_type']
  target_id   = params['target_id']
  content     = params['content']

  return (json ret: "error", msg: "请不要投诉自己") if reporter.id == target_id

  target_obj = case target_type
  when 'u'
    User.find_by(id: target_id)
  when 'q'
    Question.find_by(id: target_id)
  when 'an'
    Answer.find_by(id: target_id)
  when 'ar'
    Article.find_by(id: target_id)
  end
  return (json ret: "error", msg: "投诉对象有误") unless target_obj

  # create report for such target
  report = target_obj.reports.build(reporter: reporter)
  report.content = content
  target_obj.is_reported = true
  if report.valid? && target_obj.valid?
    target_obj.save
    report.save
    json ret: "success"
  else
    json ret: "error", msg: "投诉保存失败"
  end
end
