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
      ret = []

      results.each do |q|
        ret << {
          "id"      => q.id,
          "title"   => q.title,
          "votes"   => q.scores,
          "has_acc" => !q.accepted_answer.nil?
        }
      end

      json num: ret.size, data: ret.to_json
    end
  end
end
