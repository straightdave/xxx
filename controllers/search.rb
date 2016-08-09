get '/search' do
  if (search_str = ERB::Util.h(params['q'])) &&
     (keys = search_str.split '+') &&
     keys.size > 0

    @results = Question.ft_search keys
    @search_str = search_str.gsub('+', ' ')
    @title = "搜索结果"
    erb :search_result
  else
    @title = "搜索"
    erb :search, layout: false
  end
end

post '/search_title' do
  if (search_str = ERB::Util.h(params['q'])) &&
     (keys = search_str.split '+') &&
     keys.size > 0

    results = Question.ft_search_title keys
    if results && results.size > 0
      json num: results.size, data: results.to_json
    end
  end
end
