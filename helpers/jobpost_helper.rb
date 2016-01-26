helpers do
  def get_jobs
    Job.order(created_at: :desc).take(4)
  end

  def get_jobpost
    erb :partial_jobpost, layout: false, locals: { jobs: get_jobs }
  end
end
