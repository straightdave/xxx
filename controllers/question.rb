#controller for questions
get '/q' do
  sort_way = params['sort']
  number = params['num'] if params['num'].to_i > 0
  number ||= 10

  case sort_way
    when 'views' then
      qs = Question.order(views: :desc, created_at: :desc).take(number)
    when 'score' then
      qs = Question.order(score: :desc, created_at: :desc).take(number)
    else
      qs = Question.order(created_at: :desc).take(number)
  end
  json qs
end

get '/q/:id' do |id|
  q = Question.find(id) if Question.exists?(id)
  json q
end

