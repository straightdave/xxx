get '/articles' do
  @navbar_active = "articles"
  @title = "文章"
  @breadcrumb = [
    {name: "首页", url: '/'},
    {name: "文章", active: true}
  ]
  erb :article_home
end
