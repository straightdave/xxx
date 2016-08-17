# page of one tag
get '/t/:tid' do |tid|
  raise not_found unless @tag = Tag.find_by(id: tid)

  if !(@slice = params['slice']) || (@slice.to_i <= 0)
    @slice = 50
  else
    @slice = @slice.to_i
  end

  if !(@page = params['page']) || (@page.to_i <= 0)
    @page = 1
  else
    @page = @page.to_i
  end

  @sort_by = params['sort'] || 'hot'

  if (search_str = ERB::Util.h(params['q'])) &&
    (keys = search_str.split '+') &&
    keys.size > 0

    # note: returned @questions is not ActiveRecord::Relations but a array
    # should use ruby array methods to deal with
    @questions = Question.ft_search_intag(keys, @tag.id)
    total_size = @questions.count

    @questions = case @sort_by
    when 'hot'
      @questions.sort { |a, b| b.views <=> a.views }
                .slice(@slice * (@page - 1) .. @slice * @page)
    when 'new'
      @questions.sort { |a, b| b.created_at <=> a.created_at }
                .slice(@slice * (@page - 1) .. @slice * @page)
    end
  else
    # no search filtered but all questions with this tag
    # use methods for ActiveRecord::Relations
    total_size = @tag.questions.count
    @questions = case @sort_by
    when 'hot'
     @tag.questions.order(views: :desc)
         .limit(@slice).offset(@slice * (@page - 1))
    when 'new'
     @tag.questions.order(created_at: :desc)
         .limit(@slice).offset(@slice * (@page - 1))
    end
  end
  @total_page = total_size / @slice + (total_size % @slice != 0 ? 1 : 0)

  # find top 5 experts for this tag
  @top_experts = @tag.top_experts 5

  # edit by moderators
  @can_edit = login? &&
              (user = User.find_by(id: session[:user_id])) &&
              (user.role == User::Role::MODERATOR)

  @title = "标签：#{ @tag.name }"
  @navbar_active = "tags"
  @breadcrumb = [
    { name: "首页", url: '/' },
    { name: "标签", url: '/tags' },
    { name: "#{ @tag.name }", active: true }
  ]
  erb :tag
end

# update tags by moderators
post '/t/:tid' do |tid|
  login_filter required_roles: [ User::Role::MODERATOR ]

  unless tag = Tag.find_by(id: tid)
    return json ret: "error", msg: "tag_error"
  end

  old_name = tag.name
  old_desc = tag.desc

  tag.name = params['tname']
  tag.desc = params['tdesc']
  if tag.valid?
    tag.save

    AdminLog.create(
      :user_id => get_user_id,
      :log_text => "Moderator #{get_login_name} \
      修改了tag #{old_name}, name: #{old_name} => #{tag.name}, #{old_desc} => #{tag.desc}"
    )

    json ret: "success", msg: tag.id
  else
    json ret: "error", msg: "failed"
  end
end

# only used in asking page, ajax search
post '/tag/search' do
  user = login_filter

  category = params['category'] || 'knowledge'

  can_create = (user.reputation > 1500 || settings.ignore_repu_limit)

  if (search_str = ERB::Util.h(params['q'])) &&
     (keys = search_str.split '+') &&
     keys.size > 0

    if results = (Tag.ft_search_name keys, category)
      json num: results.size, data: results.to_json, can_create: can_create
    else
      json can_create: can_create
    end
  end
end

post '/tag/new' do
  author = login_filter

  if author.reputation < 1500 && !settings.ignore_repu_limit
    return json ret: "error", msg: "声望不足，无法创建tag"
  end

  if (name = ERB::Util.h(params['name'])) && (desc = ERB::Util.h(params['desc']))
    new_tag = Tag.new
    new_tag.name = name
    new_tag.desc = desc
    new_tag.category = 'knowledge'  # here creates knowledge scope tags only
    new_tag.created_by = author.id

    if new_tag.valid?
      new_tag.save
      json ret: "success", msg: new_tag.id
    else
      json ret: "error", msg: "新标签保存失败"
    end
  else
    json ret: "error", msg: "缺少内容"
  end
end

# home page for all tags
get '/tags' do
  if !(@slice = params['slice']) || (@slice.to_i <= 0)
    @slice = 50
  else
    @slice = @slice.to_i
  end

  if !(@page = params['page']) || (@page.to_i <= 0)
    @page = 1
  else
    @page = @page.to_i
  end

  @sort_by = params['sort'] || 'hot'

  if (search_str = ERB::Util.h(params['q'])) &&
     (keys       = search_str.split '+') &&
     (keys.size  > 0)
    @tags = Tag.ft_search keys
    total_size = @tags.count

    @tags = case @sort_by
    when 'hot'
      @tags.sort { |a, b| b.used <=> a.used }
           .slice(@slice * (@page - 1) .. @slice * @page)
    when 'new'
      @tags.sort { |a, b| b.created_at <=> a.created_at }
           .slice(@slice * (@page - 1) .. @slice * @page)
    end
  else
    total_size = Tag.count
    @tags = case @sort_by
    when 'hot'
      Tag.order(used: :desc).limit(@slice).offset(@slice * (@page - 1))
    when 'new'
      Tag.order(created_at: :desc).limit(@slice).offset(@slice * (@page - 1))
    end
  end
  @total_page = total_size / @slice + (total_size % @slice != 0 ? 1 : 0)

  @title = "标签大全"
  @navbar_active = "tags"
  @breadcrumb = [
    { name: "首页", url: '/' },
    { name: "标签", active: true }
  ]
  erb :tag_all
end
