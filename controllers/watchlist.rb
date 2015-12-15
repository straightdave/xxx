# == watching list page ==
get '/user/watchlist' do
  unless user = User.find_by(id: session[:user_id])
    return (json ret: "error", msg: "need_login|account_error")
  end
  @title = "我关注的"
  @watchlist = user.watching_questions
  @breadcrumb = [
    {name: "首页", url: '/'},
    {name: "我关注的", active: true}
  ]
  erb :my_watchlist
end
