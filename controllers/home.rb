# controller for homepage
get '/' do
  @sort_by = params['sort'] || 'default'
  number = params['num'] if params['num'].to_i > 0
  number ||= 20

  tmp = case @sort_by
        when 'views'
          Question.order(views: :desc, created_at: :desc)
        when 'noanswer'
          Question.joins("LEFT OUTER JOIN answers ON questions.id = answers.question_id")
                  .where("answers.question_id IS NULL")
                  .order("questions.created_at desc")
        else
          Question.order(created_at: :desc)
        end
  @qs = tmp.take(number)

  # calculate hot tags
  # top is using tag's attribute 'used' which is not so accurate
  # TODO: later we could find better way to count how hot tags are
  @hot_tags = Tag.top_used(20)
  @navbar_active = "qna"
  @title = "首页"
  erb :home
end
