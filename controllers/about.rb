get '/about' do
  @title = "关于"
  @navbar_active = "about"
  erb :about
end

get '/terms' do
  @title = "条款"
  erb :terms
end

get '/help' do
  @title = "帮助"
  erb :help
end


# TODO: delete this
get '/show_session' do
  data = ""
  session.each { |k, v| data += "#{k} => #{v}<br>" }
  session.class.inspect + "<br>" + session.methods.sort.inspect + "<br>" + data
end

get '/404' do
  erb :page_404, layout: false
end

get '/err' do
  1/0
end

not_found do
  erb :page_404, layout: false
end

error do
  erb :page_error, layout: false
end
