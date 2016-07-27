helpers do
  def login?
    session[:login_name] != nil && session[:user_id] != nil
  end

  def log_in(user)
    session[:user_id]         = user.id
    session[:login_name]      = user.login_name
    session[:message_amount]  = user.inbox_messages.where(isread: false).size
    session[:user_avatar_url] = user.avatar_src
  end

  def log_out
    session.destroy
  end

  # general user status check
  def login_filter(attr = {})
    is_get = (request.request_method == 'GET')

    # 1. check login
    unless login?
      if is_get
        redirect to('/user/signin?returnurl=' + CGI.escape(request.path))
      else
        halt 555, (json ret: "error", msg: "请先登录")
      end
    end

    # 2. check account
    unless user = @_current_user
      if is_get
        redirect to("/notice?reason=accounterror&ext_0=#{user.login_name}")
      else
        halt 555, (json ret: "error", msg: "登录账户数据有误")
      end
    end

    # 3. check status filtering
    status = attr[:required_status]

    if status != false
      # if status == false (literally, the boolean value)
      # it will not check this part, which means
      # ALL status can access

      if status.nil? || status.empty?
        status = [ User::Status::NORMAL ]
      end

      if status.index(user.status).nil? && !settings.ignore_status_limit
        if is_get
          redirect to("/notice?reason=statuserror&ext_0=#{user.login_name}&ext_1=#{user.status}")
        else
          halt 555, (json ret: "error", msg: "账户当前状态有误")
        end
      end
    end

    # 4. check roles filtering
    roles = attr[:required_roles]

    if roles != false
      if roles.nil? || roles.empty?
        roles = [ User::Role::USER ]
      end

      if roles.index(user.role).nil? && !settings.ignore_roles_limit
        if is_get
          redirect to("/notice?reason=roleerror&ext_0=#{user.login_name}&ext_1=#{user.role}")
        else
          halt 555, (json ret: "error", msg: "账户角色有误")
        end
      end
    end

    user  # end: if all OK, return current user object
  end
end
