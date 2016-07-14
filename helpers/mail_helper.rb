helpers do
  def send_validation_mail(user)
    if settings.mail_validation   # || true  # also send mail in dev env

      # body rendering
      body = erb :mail_tpl_confirm, :layout => false, :locals => {
        :nick_name  => user.info.nickname,
        :site_host  => settings.site_host,
        :user_id    => user.id,
        :user_vcode => user.vcode
      }

      send_mail_job({
        :type        => MailLog::TYPE::USER_CONFIRM,
        :from        => 'noreply@hanfeizishuo.com',
        :to          => user.email,
        :receiver_id => user.id,
        :subject     => "是非说用户验证",
        :body        => body,
        :time        => Time.now.to_i
      })

    else
      return "Not to send since in no production env."
    end
  end

  def send_refind_mail(user)
    # body rendering
    body = erb :mail_tpl_refind, :layout => false, :locals => {
      :nick_name  => user.info.nickname,
      :site_host  => settings.site_host,
      :user_id    => user.id,
      :user_vcode => user.vcode
    }

    send_mail_job({
      :type        => MailLog::TYPE::RESET_PASSWORD,
      :from        => 'noreply@hanfeizishuo.com',
      :to          => user.email,
      :receiver_id => user.id,
      :subject     => "是非说重置密码",
      :body        => body,
      :time        => Time.now.to_i
    })
  end

  private
  def send_mail_job(data)
    mail_log = MailLog.new
    mail_log.type        = data[:type]
    mail_log.from        = data[:from]
    mail_log.to          = data[:to]
    mail_log.receiver_id = data[:receiver_id]
    mail_log.save if mail_log.valid?

    data[:log_id] = mail_log.id

    @rc = get_redis_client
    begin
      @rc.lpush(settings.redis_conf[:mail_queue], data.to_json)
      mail_log.status = MailLog::STATUS::SENDING
    rescue
      mail_log.status = MailLog::STATUS::ERROR
    end
    mail_log.save if mail_log.valid?
  end

  def get_redis_client
    @rc || Redis.new(
      :host => settings.redis_conf[:host],
      :port => settings.redis_conf[:port],
      :db   => settings.redis_conf[:db]
    )
  end
end
