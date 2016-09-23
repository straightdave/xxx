# controller for homepage
get '/' do
  sort_by = params['tab'] || 'default'
  number  = (params['num'] if params['num'].to_i > 0) || 50

  @qs = case sort_by
  when 'hot'
    # only show questions with status of normal, no_commenting, frozen
    Question.where(status: [0, 1, 2]).order(views: :desc, created_at: :desc)
  when 'unanswered'
    Question.joins("LEFT OUTER JOIN answers ON questions.id = answers.question_id")
            .where("answers.question_id IS NULL")
            .order("questions.created_at desc")
  else
    Question.where(status: [0, 1, 2]).order(created_at: :desc)
  end.take(number)

  @title = I18N.ref "homepage_title"
  erb :home
end
