get '/drafts' do
  @user = login_filter required_status: false, required_roles: false
  @title = "我的草稿"
  erb :user_drafts
end

get '/draft/:id' do |id|
  user = login_filter required_status: false, required_roles: false
  draft = user.drafts.where(id: id).first

  unless draft
    return json ret: "error", msg: "该用户没有id为#{id}的草稿"
  end
  json ret: "success", type: draft.draft_type, content: draft.content
end

post '/draft/:id/delete' do |id|
  user = login_filter required_status: false, required_roles: false
  draft = user.drafts.where(id: id).first

  unless draft
    return json ret: "error", msg: "该用户没有id为#{id}的草稿"
  end

  begin
    draft.destroy!
  rescue
    json ret: "error", msg: "删除草稿失败"
  end
  json ret: "success"
end

post '/draft' do
  user = login_filter required_status: false, required_roles: false

  title = ERB::Util.h params['title']
  if title.nil? || title.empty?
    title = "草稿"
  end

  title = title + " " + Time.now.localtime.strftime("%I:%M:%S%P")

  case params['type']
  when 'question'.freeze then type = 0
  when 'article'.freeze  then type = 1
  else
    return json ret: "error", msg: "错误的草稿类型 #{ params['type'] }"
  end

  data = params['data']

  draft = Draft.new
  draft.title = title
  draft.draft_type = type
  draft.content = data
  draft.user_id = user.id

  if draft.valid?
    if user.drafts.count >= 10
      oldest = user.drafts.first
      oldest.destroy
    end

    draft.save
    json ret: "success", msg: draft.id
  else
    json ret: "failed", msg: "draft save failed"
  end
end
