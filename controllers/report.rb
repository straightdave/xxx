# reporting related actions here
# clicking buttons on pages of targets (users or works)
# modal windows pop-up and input text on it then submit
# all reports will be reviewed by admins

# create a report via ajax
post '/report' do
  reporter = login_filter

  if (reporter.reputation <= 200) && (!settings.ignore_repu_limit)
    return (json ret: "error", msg: "声望值不足200，无法投诉")
  end

  # interface to front-end
  # target_type: string, name of reporting target type
  #   'u' -> 'User', 'q' -> 'Question', 'an' -> 'answer', 'ar' -> 'article'
  # target_id: int, reporting target id
  # content: string, content of report
  target_type = params['target_type']
  target_id   = params['target_id']
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
  return (json ret: "error", msg: "投诉对象有误") unless target_obj

  if target_type == 'u'
    # for user which get reported
    if target_obj.id == reporter.id
      return (json ret: "error", msg: "请不要投诉自己")
    end
  else
    # item which get reported has field 'author' - they are posts
    if target_obj.author.id == reporter.id
      return (json ret: "error", msg: "请不要投诉自己的作品")
    end
  end

  # make sure one target only get one report per person
  if target_obj.reports.exists?(user_id: session[:user_id])
    return json ret: "error", msg: "你已经投诉过这个了"
  end

  # create report for such target
  report = target_obj.reports.build(reporter: reporter)
  report.content = content
  target_obj.has_reports += 1

  # reports may cause status changes to questions and articles
  # considering about how many they are viewed
  if target_type == 'q' || target_type == 'ar'
    if target_obj.has_reports >= (target_obj.views / 4) &&
       target_obj.has_reports >= 5
      target_obj.status = 2 # frozen
    elsif target_obj.has_reports >= (target_obj.views / 2) &&
          target_obj.has_reports >= 20
      target_obj.status = 3 # hiden
    end
  end

  # to reduce reputation for receiving reports
  if target_obj.has_reports >= 5
    if target_type == 'u'
      target_obj.update_reputation(-20, "got more than 5 reportings")
    else
      target_obj.author.update_reputation(-20, "posts got more than 5 reportings")
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
