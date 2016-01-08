helpers do
  def login?
    session[:login_name] != nil && session[:user_id] != nil
  end

  def login_user(user)
    session[:user_id]        = user.id
    session[:login_name]     = user.login_name
    session[:message_amount] = user.inbox_messages.where(isread: false).size

    user.last_login_ip = request.ip
    user.last_login_at = Time.now
    user.save if user.valid?
  end

  def logout_user
    session.destroy
  end

  def add_repu(user, points)
    user.info.reputation += points
    user.info.save if user.info.valid?
  end

  def minus_repu(user, points)
    user.info.reputation -= points
    user.info.save if user.info.valid?
  end

  # used for views
  def get_login_name
    get :login_name
  end

  def get_message_amount
    get :message_amount
  end

  def get_user_id
    get :user_id
  end

  private
  def get(attr)
    session[attr]
  end
end
