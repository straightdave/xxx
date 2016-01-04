# == about tags ==
get '/t/:tid' do |tid|
  if @tag = Tag.find_by(id: tid)
    @title = "标签：#{@tag.name}"
    erb :question_of_tag
  else
    redirect to('/404')
  end
end

get '/tags' do
  "tags here"
end
