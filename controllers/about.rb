get '/about' do
  @title = "关于"
  erb :about
end

get '/terms' do
  @title = "条款"
  erb :terms
end
