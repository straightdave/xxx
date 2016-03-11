helpers do
  def render_ad
    erb :partial_ad, layout: false
  end

  def render_job_posts
    erb :partial_jobpost, layout: false, locals: { jobs: Job.get_jobs }
  end

  def render_breadcrumb
    erb :partial_breadcrumb, layout: false
  end
end
