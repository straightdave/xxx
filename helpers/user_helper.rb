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
    session[:login_name]
  end
  def get_message_amount
    session[:message_amount]
  end
  def get_user_id
    session[:user_id]
  end

  # eneral login checking for each action
  def login_filter(attr = {})
    req_path   = request.path

    # 1. check login
    unless login?
      redirect to('/login?r=' + CGI.escape(req_path) + '&w=1')
    end

    # 2. check account
    unless user = User.find_by(id: session[:user_id])
      redirect to('/login?r=' + CGI.escape(req_path) + '&w=3')
    end

    # 3. check status filtering
    status = attr[:required_status]
    if status.nil? || status.empty?
      status = [ User::Status::NORMAL ]
    end

    if status.index(user.status).nil? && !settings.status_no_limit
      redirect to('/login?r=' + CGI.escape(req_path) + '&w=4')
    end

    # 4. check roles filtering
    roles = attr[:required_roles]
    if roles.nil? || roles.empty?
      roles = [ User::Role::USER ]
    end

    if roles.index(user.role).nil? && !settings.roles_no_limit
      redirect to('/login?r=' + CGI.escape(req_path) + '&w=4')
    end
  end

end
