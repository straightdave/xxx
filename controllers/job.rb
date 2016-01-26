get '/jobs' do
  @title = "职位大全"
  @navbar_active = "jobs"
  @breadcrumb = [
    {name: "首页", url: '/'},
    {name: "职位", active: true}
  ]
  erb :job_home
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
