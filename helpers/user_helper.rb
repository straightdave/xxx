require 'digest'

helpers do
  def add_salt(passwd, salt)
    Digest::MD5.hexdigest(passwd << salt)
  end

  def login?
    session[:login_email] != nil
  end

  def send_activate_mail(login_email)
    # add into mailing queue
  end

  def should_login_as(who)
    
  end

end
