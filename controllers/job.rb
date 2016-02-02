get '/jobs' do
  @title = "职位大全"
  @navbar_active = "jobs"
  erb :job_home
end

post '/jobs' do
  return (json ret: "error", msg: "need_login") unless login?
  author = User.find_by(id: session[:user_id])

  
end


get '/job/:id' do |id|
  @job = Job.find_by(id: id)
  raise not_found unless @job

  @title = @job.title
  @breadcrumb = [
    {name: "首页", url: '/'},
    {name: "职位", url: '/jobs'},
    {name: @job.title, active: true}
  ]
  erb :job
end
