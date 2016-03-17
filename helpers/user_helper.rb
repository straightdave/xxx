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

  # general login check
  def login_filter(attr = {})
    req_path   = CGI.escape(request.path)
    req_method = request.request_method
    is_get = req_method == 'GET'

    # 1. check login
    unless login?
      if is_get
        redirect to('/login?r=' + req_path + '&w=1')
      else
        response.body = json ret: "error", msg: "请先登录"
        halt 200
      end
    end

    # 2. check account
    unless user = User.find_by(id: session[:user_id])
      if is_get
        redirect to('/login?r=' + req_path + '&w=3')
      else
        response.body = json ret: "error", msg: "账户好像有问题"
        halt 200
      end
    end

    # 3. check status filtering
    status = attr[:required_status]
    if status.nil? || status.empty?
      status = [ User::Status::NORMAL ]
    end

    if status.index(user.status).nil? && !settings.status_no_limit
      if is_get
        redirect to('/login?r=' + req_path + '&w=4')
      else
        response.body = json ret: "error", msg: "账户状态有误"
        halt 200
      end
    end

    # 4. check roles filtering
    roles = attr[:required_roles]
    if roles.nil? || roles.empty?
      roles = [ User::Role::USER ]
    end

    if roles.index(user.role).nil? && !settings.roles_no_limit
      if is_get
        redirect to('/login?r=' + req_path + '&w=4')
      else
        response.body = json ret: "error", msg: "账户角色有误"
        halt 200
      end
    end
  end

end
