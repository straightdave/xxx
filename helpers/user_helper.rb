helpers do
  def login?
    session[:login_name] != nil && session[:user_id] != nil
  end

  def login_user(user)
    session[:login_name] = user.login_name
    session[:user_id] = user.id
    session[:message_amount] = user.inbox_messages.where(isread: false).size
    user.last_login_ip = request.ip
    user.last_login_at = Time.now
    user.save if user.valid?
  end

  def logout_user
    session.destroy
  end
end
