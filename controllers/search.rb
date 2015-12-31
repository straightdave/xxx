# searching page (search box and results if any)
get '/search' do
  if (search_str = params['q']) &&
     (keys = search_str.split '+') &&
     keys.size > 0

    # do some search work
    @results = Question.ft_search keys
    @search_str = search_str.gsub('+', ' ')
    @title = "搜索结果"
    erb :search_result
  else
    @title = "搜索"
    erb :search, layout: false
  end
end
