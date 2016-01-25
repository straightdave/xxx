helpers do
  def send_validation_mail(user)
    to      = user.info.email
    subject = "韩非子说用户验证"
    content = "亲爱滴#{user.info.nickname}你好，请点击或复制链接 #{settings.site_host}/user/validation?id=#{user.id}&code=#{user.vcode} 以激活你的账户。成功激活后就可以提问和回答问题了。"

    data = { to: to, subject: subject, content: content, time: Time.now.to_i }
    send_mail_job(data)
  end

  private
  def get_redis_client
    begin
      @rc || (Redis.new(
        :host => settings.redis_conf[:host],
        :post => settings.redis_conf[:port],
        :db   => settings.redis_conf[:db]
      ))
    rescue Exception => e
      puts e.message
    end
  end

  def send_mail_job(data)
    begin
      @rc = get_redis_client
      @rc.lpush(settings.redis_conf[:mailer_list], data.to_json)
    rescue Exception => e
      puts e.message
    end
  end
end
