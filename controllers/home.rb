# controller for homepage
get '/' do
  @sort_by = params['sort'] || 'default'
  number = params['num'] if params['num'].to_i > 0
  number ||= 10

  case @sort_by
    when 'views' then
      @qs = Question.order(views: :desc, created_at: :desc).take(number)
    when 'votes' then
      @qs = Question.order(votes: :desc, created_at: :desc).take(number)
    else
      @qs = Question.order(created_at: :desc).take(number)
  end
  erb :home
end
