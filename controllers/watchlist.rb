# == watching list page ==
get '/user/watchlist' do
  login_filter
  user = User.find_by(id: session[:user_id])

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

  @watchlist = user.watched_questions
  total_number = @watchlist.count
  @total_page = total_number / @slice
  @total_page += 1 if total_number % @slice != 0

  @title = "我关注的"
  @breadcrumb = [
    { name: "首页", url: '/' },
    { name: "我关注的", active: true }
  ]
  erb :my_watchlist
end
