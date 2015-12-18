get '/about' do
  @title = "关于"
  erb :about
end

get '/terms' do
  @title = "条款"
  erb :terms
end

# TODO: delete this
get '/show_session' do
  data = ""
  session.each { |k, v| data += "#{k} => #{v}<br>"}

  session.class.inspect + "<br>" +
  session.methods.sort.inspect + "<br>" +
  data
end

get '/404' do
  erb :page_404, layout: false
end
