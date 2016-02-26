# reporting related actions here
# clicking buttons on pages of targets (users or works)
# modal windows pop-up and input text on it then submit
# all reports will be reviewed by admins

# create a report via ajax
post '/report' do
  return (json ret: "error", msg: "need_login") unless login?

  reporter = User.find_by(id: session[:user_id])
  return (json ret: "error", msg: "account_error") unless reporter
  return (json ret: "error", msg: "status_error") if reporter.status != User::NORMAL

  # interface to front-end
  # target_type: string, name of reporting target type
  #              'u' -> 'User', 'q' -> 'Question', 'an' -> 'answer', 'ar' -> 'article'
  # target_id: int, reporting target id
  # content: string, content of report
  target_type = params['target_type']
  target_id   = parmas['target_id']
  content     = params['content']

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
  return (json ret: "error", msg: "wrong_target") unless target_obj

  # create report for such target
  report = target_obj.reports.build(reporter: reporter)
  report.content = content
  if report.valid?
    report.save
    json ret: "success"
  else
    json ret: "error", msg: "create_report_failed"
  end
end
