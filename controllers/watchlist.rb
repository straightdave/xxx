# == watching list page ==
get '/user/watchlist' do
  login_filter
  user = User.find_by(id: session[:user_id])

  @title = "我关注的"
  @watchlist = user.watched_questions
  @breadcrumb = [
    { name: "首页", url: '/' },
    { name: "我关注的", active: true }
  ]
  erb :my_watchlist
end
