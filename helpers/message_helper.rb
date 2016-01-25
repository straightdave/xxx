helpers do
  def send_msg_after_ask(author, question)
    send_inbox_msg from_uid: 0,
                   to_uid:   author.id,
                   subject:  "您提出一条问题",
                   content:  "您提出了问题：<a href='/q/#{question.id}'>
                              #{question.title}</a><br>可以在站内信中关注问题动态。"
  end

  def send_msg_after_answer(question, answerer)
    send_inbox_msg from_uid: 0,
                   to_uid:   question.author.id,
                   subject:  "您的问题有动静了",
                   content:  "<a href='/u/#{answerer.login_name}'>
                              #{answerer.info.nickname}</a>回答了您的问题
                              <a href='/q/#{question.id}'>#{question.title}
                              </a>"
  end

  def send_welcome_message(user)
    send_inbox_msg from_uid: 0,
                   to_uid:   user.id,
                   subject:  "#{user.info.nickname}，感谢您的加入",
                   content:  "欢迎，您可以在<a href='/user/profile'>
                              这里</a>补充个人信息"
  end

  private
  def send_inbox_msg(args = {})
    msg = Message.new
    msg.from_uid = args[:from_uid]
    msg.to_uid   = args[:to_uid]
    msg.subject  = args[:subject]
    msg.content  = args[:content]
    msg.sent_at  = Time.now
    if msg.valid?
      msg.save
      session[:message_amount] += 1 unless session[:message_amount].nil?
    end
  end
end
