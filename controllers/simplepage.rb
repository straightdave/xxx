get '/help' do
  @title = "帮助"
  erb :help
end

get '/terms' do
  @title = "条款"
  erb :terms
end

get '/404' do
  erb :page_404, layout: false
end

get '/err' do
  1/0
end

not_found do
  erb :page_404, layout: false
end

error 400..550 do
  @title = "{Error!}"
  @reason = "#{env['sinatra.error'].message}"
  @sub_reason = "如果您认为是bug，可以发邮件至<a href='mailto:bug@shifeishuo.com'>bug@shifeishuo.com</a>报告"
  erb :page_error, layout: false
end

get '/notice' do
  reason = params['reason'] || ""
  reason = reason.to_sym

  case reason
  when :accounterror
    name   = params['ext_0']
    @title   = "账户有误"
    @content = "系统中你的账户（登录名：#{name}）状态有误，可能是因为操作中丢失了登录信息所致。
                你可以再次 <a href='/user/signin?u=#{name}'>登录</a>。<br />
                给您带来的不便请谅解"
  when :statuserror
    name   = params['ext_0']
    status = User.get_status_zh(params['ext_1'].to_i)
    @title   = "账户状态有误"
    @content = "您的账户（登录名：#{name}）当前的用户状态是（#{status}），无法进行此次操作。"
  when :roleerror
    name = params['ext_0']
    role = User.get_role_zh(params['ext_1'].to_i)
    @title   = "账户角色有误"
    @content = "您的账户（登录名：#{name}）当前的角色是（#{role}），无法进行此次操作。"
  when :validok
    @title   = "恭喜，您的账户已通过验证"
    @content = "<a href='/'>回到首页</a>"
  when :validfailed
    @title   = "很遗憾，账户验证失败"
    @content = "这很可能是由于验证信息中得验证码过期导致的，您可以尝试重新发送验证邮件 <br />
                登陆后，进入“我的资料”下即可找到“重新发送验证邮件”的按钮"
  else
    @title   = "消息页面"
    @content = "您可以浏览“是非说”网站的精彩内容，或者参与其中： <a href='/user/signin'>登录</a>"
  end

  erb :page_info
end


# TODO: delete this
get '/show_session' do
  data = ""
  session.each { |k, v| data += "#{k} => #{v}<br>" }
  session.class.inspect + "<br>" + session.methods.sort.inspect + "<br>" + data
end

