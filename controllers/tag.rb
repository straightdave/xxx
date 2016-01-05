# == about tags ==
get '/t/:tid' do |tid|
  if @tag = Tag.find_by(id: tid)
    @title = "标签：#{@tag.name}"
    @navbar_active = "tags"
    @breadcrumb = [
      {name: "首页", url: '/'},
      {name: "标签", url: '/tags'},
      {name: "#{@tag.name}", active: true}
    ]

    @sort_by = params['sort'] || 'hot'
    @page = params['page'] || 1    # 20 tags per page
    @page = @page.to_i

    total_size = @tag.questions.count
    @total_page = total_size / 20 + (if total_size % 20 != 0 then 1 else 0 end)
    if @sort_by == 'hot'
      @questions = @tag.questions.order(views: :desc).limit(20).offset(20 * (@page - 1))
    elsif @sort_by == 'new'
      @questions = @tag.questions.order(created_at: :desc).limit(20).offset(20 * (@page - 1))
    end

    erb :tag
  else
    raise not_found
  end
end

post '/tags/search' do

end

get '/tags' do
  @title = "标签大全"
  @navbar_active = "tags"
  @breadcrumb = [
    {name: "首页", url: '/'},
    {name: "标签", active: true}
  ]
  @sort_by = params['sort'] || 'hot'
  @page = params['page'] || 1    # 20 tags per page
  @page = @page.to_i
  total_size = Tag.count
  @total_page = total_size / 20 + (if total_size % 20 != 0 then 1 else 0 end)
  if @sort_by == 'hot'
    @tags = Tag.order(used: :desc).limit(20).offset(20 * (@page - 1))
  elsif @sort_by == 'new'
    @tags = Tag.order(created_at: :desc).limit(20).offset(20 * (@page - 1))
  end
  erb :tag_home
end
