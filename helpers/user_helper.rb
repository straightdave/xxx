helpers do
  def login?
    session[:login_name] != nil && session[:user_id] != nil
  end

  def log_in(user)
    session[:user_id]        = user.id
    session[:login_name]     = user.login_name
    session[:message_amount] = user.inbox_messages.where(isread: false).size
    user.save if user.valid?
  end

  def log_out
    session.destroy
  end

  # used for views
  def get_login_name
    getss :login_name
  end

  def get_message_amount
    getss :message_amount
  end

  def get_user_id
    getss :user_id
  end

  private
  def getss(attr)
    session[attr]
  end
end
