get '/drafts' do
  @user = login_filter
  @title = "我的草稿"
  erb :user_drafts
end

get '/draft/:id' do |id|
  user = login_filter
  draft = user.drafts.where(id: id).first

  unless draft
    return json ret: "error", msg: "该用户没有id为#{id}的草稿"
  end
  json ret: "success", type: draft.draft_type, content: draft.content
end

post '/draft/:id/delete' do |id|
  user = login_filter
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
  user = login_filter

  title = params['title']
  if title.nil? || title.empty?
    title = "草稿"
  end

  case params['type']
  when 'question' then type = 0
  when 'article'  then type = 1
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
    json ret: "success"
  else
    json ret: "failed", msg: "draft save failed"
  end
end
