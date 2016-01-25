helpers do
  def get_jobs
    Job.order(created_at: :desc).take(4)
  end
end
