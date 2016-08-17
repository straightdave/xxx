# reporting related actions here
# clicking buttons on pages of targets (users or works)
# modal windows pop-up and input text on it then submit
# all reports will be reviewed by admins

# create a report via ajax
post '/report' do
  reporter = login_filter

  # interface to front-end
  # target_type: string, name of reporting target type
  #   'u' -> 'User', 'q' -> 'Question', 'an' -> 'answer', 'ar' -> 'article'
  # target_id: int, reporting target id
  # content: string, content of report
  target_type = ERB::Util.h params['target_type']
  target_id   = ERB::Util.h params['target_id']
  content     = ERB::Util.h params['content']

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

  if target_type == 'u'
    if target_obj.id == reporter.id
      return json ret: "error", msg: "请不要投诉自己"
    end
  else
    if target_obj.author.id == reporter.id
      return json ret: "error", msg: "请不要投诉自己的作品"
    end
  end

  if (reporter.reputation <= 200) && (!settings.ignore_repu_limit)
    return json ret: "error", msg: "声望值不足200，无法投诉"
  end

  # user whose repu >= 50k can do many times on same object
  if target_obj.reports.exists?(user_id: reporter.id) &&
     reporter.reputation < 50000
    return json ret: "error", msg: "同一用户对于同一个对象只能投诉一次"
  end

  report = target_obj.reports.build(reporter: reporter)
  report.content = content
  target_obj.has_reports += 1

  if target_obj.has_reports > 5
    if target_type == 'u'
      target_obj.update_reputation! by: -100, since: "user got 6 or more reports"
    else
      target_obj.author.update_reputation! by: -100, since: "one post got 6 or more report"
    end
  end

  if report.valid? && target_obj.valid?
    target_obj.save
    report.save
    json ret: "success"
  else
    json ret: "error", msg: "投诉创建失败"
  end
end
