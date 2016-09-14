# controller for homepage
get '/' do
  @sort_by = params['tab'] || 'default'
  number   = params['num'] if params['num'].to_i > 0
  number ||= 50

  tmp = case @sort_by
  when 'hot'
    # only show questions with status of normal, no_commenting, frozen
    Question.where(status: [0, 1, 2]).order(views: :desc, created_at: :desc)
  when 'noanswer'
    Question.joins("LEFT OUTER JOIN answers ON questions.id = answers.question_id")
            .where("answers.question_id IS NULL")
            .order("questions.created_at desc")
  else
    Question.where(status: [0, 1, 2]).order(created_at: :desc)
  end
  @qs = tmp.take(number)

  # calculate hot tags
  # top is using tag's attribute 'used' which is not so accurate
  # TODO: later we could find better way to count how hot tags are
  @hot_tags = Tag.top_used(20)

  @title          = I18N.ref("homepage_title")
  @hide_header    = true if login?
  erb :home
end
