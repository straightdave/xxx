# update user's (own) profile
post '/user/profile' do
  user = login_filter required_status: false, required_roles: false

  email_changed = (user.email != ERB::Util.h(params['email']))
  if email_changed && !user.can_change_email
    return json ret: "error", msg: "当前状态不允许修改主邮箱"
  end

  user.info.nickname = ERB::Util.h params['nickname']
  user.info.intro    = ERB::Util.h params['intro']
  user.info.phone    = ERB::Util.h params['phone']
  user.info.city     = ERB::Util.h params['city']
  user.info.qq       = ERB::Util.h params['qq']
  user.info.wechat   = ERB::Util.h params['wechat']
  user.info.email2   = ERB::Util.h params['email2']
  user.email         = (ERB::Util.h params['email']) if email_changed
  user.info.hideemail = params['hideemail']

  if user.info.valid?
    user.info.save
    user.record_event(:update, user)

    if email_changed && user.can_change_email
      user.status = User::Status::NEWBIE
      user.gen_and_set_new_vcode
      if user.valid?
        user.save
        send_validation_mail user
      else
        return json ret: "error", msg: user.errors.messages.inspect
      end
    end
    json ret: "success"
  else
    json ret: "error", msg: user.info.errors.messages.inspect
  end
end

get '/user/profile' do
  @user = login_filter required_status: false, required_roles: false
  @title = "我的资料"
  @user_info = @user.info

  # set `validated` as `Not equal to NEWBIE` for now
  # TODO: other situation may also need to validate
  @is_validated = (@user.status != User::Status::NEWBIE)
  erb :user_update
end

# upload avatar files (maybe any file)
# not ajax calling now
post '/upload' do
  login_filter required_status: false, required_roles: false

  @title = "文件上传错误"

  unless params['file'] &&
         (tmpfile = params[:file][:tempfile]) &&
         (name = params[:file][:filename])
    @reason = "获取文件对象失败"
    @sub_reason = "表单提交失败"
    return erb :page_error, layout: false
  end

  ext = name.split('.')[-1]
  unless ["jpeg", "jpg", "png"].include? ext
    @reason = "文件类型（#{ext}）错误"
    @sub_reason = "只允许jpeg/jpg和png"
    return erb :page_error, layout: false
  end

  if tmpfile.size > 50 * 1024
    @reason = "文件尺寸错误"
    @sub_reason = "#{tmpfile.size} > #{50 * 1024}"
    return erb :page_error, layout: false
  end

  login_name = session[:login_name]
  full_name = "#{settings.avatar_folder}/#{login_name}.#{ext}"

  File.open(full_name, "w+") do |file|
    file.puts tmpfile.read
  end

  begin
    user_info = UserInfo.find_by(user_id: session[:user_id])
    user_info.avatar = "/uploads/avatars/#{login_name}.#{ext}"
    user_info.save
    json ret: "success", msg: full_name
  rescue
    @reason = "文件保存失败"
    @sub_reason = "无法保存头像"
    return erb :page_error, layout: false
  end

  # for now, redirect to current page
  redirect to("/user/profile")
end

# upload pic for wangEditor
post '/uploadeditor' do
  login_filter required_status: false, required_roles: false

  unless payload = request.POST
    return "error|服务器错误：没有找到图片内容"
  end

  begin
    tempfile = payload["uploadedimage"][:tempfile]
    raw_filename = payload["uploadedimage"][:filename]

    ext = raw_filename.split('.')[-1]
    unless ["jpeg", "jpg", "png"].include? ext
      return "error|只支持jpeg，jpg和png格式的图片"
    end

    size = tempfile.size
    if size > 200 * 1024
      return "error|图片（#{size}）不能超过200k（204800）"
    end

    login_name = session[:login_name]
    full_name = "#{settings.editorimage_folder}/#{login_name}_#{raw_filename}"

    begin
      File.open(full_name, "w+") do |file|
        file.puts tempfile.read
      end
    rescue
      return "error|保存文件失败"
    ensure
      tempfile.close
      tempfile.unlink
    end
    "#{$Scheme_host_port}/uploads/editorimages/#{login_name}_#{raw_filename}"
  rescue
    "error|服务器错误"
  end
end
