get '/ask' do
  if login?
    erb :ask
  else
    json ret: "error", msg: "need_login"    
  end
end
