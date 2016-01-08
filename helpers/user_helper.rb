helpers do
  def login?
    if session[:rememberme].nil? || session[:rememberme] == '0'
      cookies[:login_name] != nil && cookies[:user_id] != nil
    else
      session[:login_name] != nil && session[:user_id] != nil
    end
  end

  def login_user(user, rememberme = 0)
    if rememberme == 1
      session[:user_id]        = user.id
      session[:login_name]     = user.login_name
      session[:message_amount] = user.inbox_messages.where(isread: false).size
      session[:rememberme]     = '1'
    else
      cookies[:user_id]        = user.id
      cookies[:login_name]     = user.login_name
      cookies[:message_amount] = user.inbox_messages.where(isread: false).size
    end

    user.last_login_ip = request.ip
    user.last_login_at = Time.now
    user.save if user.valid?
  end

  def logout_user
    session.destroy && cookies.clear
  end

  # used for views
  def get_login_name
    if session[:rememberme] == '1'
      session[:login_name]
    else
      cookies[:login_name]
    end
  end

  def get_message_amount
    if session[:rememberme] == '1'
      session[:message_amount].to_i
    else
      cookies[:message_amount].to_i
    end
  end

  def get_user_id
    if session[:rememberme] == '1'
      session[:user_id].to_i
    else
      cookies[:user_id].to_i
    end
  end

  def add_repu(user, points)
    user.info.reputation += points
    user.info.save if user.info.valid?
  end

  def minus_repu(user, points)
    user.info.reputation -= points
    user.info.save if user.info.valid?
  end
end
