# actions for questions
get '/ask' do
  if login?
    erb :ask, layout: :basic_layout
  else
    "Not login yet"
  end
end
