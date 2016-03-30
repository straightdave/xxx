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

  def render_report_modal(type, id)
    erb :partial_report_modal, layout: false, locals: { item_type: type, item_id: id }
  end

  def render_edit_modal
    erb :partial_edit_modal, layout: false
  end

  def render_tag_edit_modal
    erb :partial_tag_edit_modal, layout: false
  end

  def render_pager
    erb :partial_pager, layout: false
  end

  def render_pager_full
    erb :partial_pager_full, layout: false
  end
end
