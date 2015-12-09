# == about tags ==
get '/t/:tid' do |tid|
  @title = "热门标签"
  erb :question_of_tag if @tag = Tag.find_by(id: tid)
end
