# == about tags ==
get '/t/:tid' do |tid|
  if @tag = Tag.find_by(id: tid)
    @sort_by = params['sort'] || 'hot'
    @page = params['page'] || 1    # 20 tags per page
    @page = @page.to_i

    @title = "标签：#{@tag.name}"
    @navbar_active = "tags"
    @breadcrumb = [
      {name: "首页", url: '/'},
      {name: "标签", url: '/tags'},
      {name: "#{@tag.name}", active: true}
    ]

    if (search_str = params['q']) &&
       (keys = search_str.split '+') &&
       keys.size > 0

      @questions = Question.ft_search_intag(keys, @tag.id)
      total_size = @questions.count
      if @sort_by == 'hot'
        @questions = @questions.sort { |a, b| b.views <=> a.views }
                               .slice(20 * (@page - 1) .. 20 * @page)
      elsif @sort_by == 'new'
        @questions = @questions.sort { |a, b| b.created_at <=> a.created_at }
                               .slice(20 * (@page - 1) .. 20 * @page)
      end
    else
      total_size = @tag.questions.count
      if @sort_by == 'hot'
        @questions = @tag.questions.order(views: :desc)
                         .limit(20).offset(20 * (@page - 1))
      elsif @sort_by == 'new'
        @questions = @tag.questions.order(created_at: :desc)
                         .limit(20).offset(20 * (@page - 1))
      end
    end

    @total_page = total_size / 20 + (if total_size % 20 != 0 then 1 else 0 end)
    erb :tag
  else
    raise not_found
  end
end

# ajax call: create a tag
post '/tags/new' do
  if (name = params['name']) && (desc = params['desc'])
    new_tag = Tag.new
    new_tag.name = name
    new_tag.desc = desc
    if new_tag.valid?
      new_tag.save
      json ret: "success", msg: new_tag.id
    else
      json ret: "error", msg: "failed"
    end
  else
    json ret: "error", msg: "lack_of_args"
  end
end

get '/tags' do
  @sort_by = params['sort'] || 'hot'
  @page = params['page'] || 1    # 20 tags per page
  @page = @page.to_i

  if (search_str = params['q']) &&
     (keys = search_str.split '+') &&
     keys.size > 0
    @tags = Tag.ft_search keys

    total_size = @tags.count
    if @sort_by == 'hot'
      @tags = @tags.sort { |a, b| b.used <=> a.used }
                   .slice(20 * (@page - 1) .. 20 * @page)
    elsif @sort_by == 'new'
      @tags = @tags.sort { |a, b| b.created_at <=> a.created_at }
                   .slice(20 * (@page - 1) .. 20 * @page)
    end
  else
    total_size = Tag.count
    if @sort_by == 'hot'
      @tags = Tag.order(used: :desc).limit(20).offset(20 * (@page - 1))
    elsif @sort_by == 'new'
      @tags = Tag.order(created_at: :desc).limit(20).offset(20 * (@page - 1))
    end
  end

  @total_page = total_size / 20 + (if total_size % 20 != 0 then 1 else 0 end)

  @title = "标签大全"
  @navbar_active = "tags"
  @breadcrumb = [
    {name: "首页", url: '/'},
    {name: "标签", active: true}
  ]
  erb :tag_home
end
