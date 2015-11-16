require 'digest'

helpers do
  def add_salt(passwd, salt)
    Digest::MD5.hexdigest(passwd << salt)
  end

  def login?
    session[:login_email] != nil
  end

  def login_user(user)
    session[:login_email] = user.login_email
    session[:user_id] = user.user_id
    user.last_login_ip = request.ip
    user.last_login_at = Time.now()
    user.save if user.valid?
  end

  def logout_user
    session[:login_email] = nil
    session[:user_id] = nil
  end

  def send_activate_mail(login_email)
    # add into mailing queue
  end

end
