helpers do
  def send_msg_after_comment(commentor, item)
    create_inbox_msg from_uid: settings.admin_uid,
                     to_uid: item.author.id,
                     subject: "#{commentor.info.nickname}给您的问题加了条注释",
                     content: "<a href='/q/#{item.id}'>点击查看</a>"
  end

  def send_msg_after_ask(author, question)
    create_inbox_msg from_uid: settings.admin_uid,
                     to_uid: author.id,
                     subject: "您提出一条问题",
                     content: "请在站内信中关注问题动态。<br>点击查看问题：
                              <a href='/q/#{question.id}'>#{question.title}</a>"
    session[:message_amount] += 1 unless session[:message_amount].nil?
  end

  def send_msg_after_answer(question, answerer)
    create_inbox_msg from_uid: settings.admin_uid,
                     to_uid: question.author.id,
                     subject: "问题有动静",
                     content: "<a href='/u/#{answerer.login_name}'>
                              #{answerer.info.nickname}</a>回答了您的问题
                              <a href='/q/#{question.id}'>#{question.title}
                              </a>"
  end

  def send_welcome_message(user)
    create_inbox_msg from_uid: settings.admin_uid,
                     to_uid: user.id,
                     subject: "#{user.info.nickname},感谢您的加入",
                     content: "欢迎，您可以在<a href='/user/profile'>
                              这里</a>补充个人信息"
  end

  private
  def create_inbox_msg(args = {})
    msg = Message.new
    msg.from_uid = args[:from_uid]
    msg.to_uid = args[:to_uid]
    msg.subject = args[:subject]
    msg.content = args[:content]
    msg.sent_at = Time.now
    msg.save if msg.valid?
  end
end
