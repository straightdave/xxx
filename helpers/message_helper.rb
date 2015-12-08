helpers do
  def send_commented_message(commentor, item)
    msg = Message.new
    msg.from_uid = settings.admin_uid
    msg.to_uid = item.author.id
    msg.subject = "#{commentor.info.nickname}给您的问题加了条注释"
    msg.content = "<a href='/q/#{item.id}'>点击查看</a>"
    msg.sent_at = Time.now()
    msg.save if msg.valid?
  end

  def send_welcome_message(user)
    msg = Message.new
    msg.from_uid = settings.admin_uid # admin's id set in app.rb/config
    msg.to_uid = user.id
    msg.subject = "#{user.info.nickname},感谢您的加入"
    msg.content = "欢迎，您可以在<a href='/user/profile'>这里</a>补充个人信息"
    msg.sent_at = Time.now
    msg.save if msg.valid?
  end
end
