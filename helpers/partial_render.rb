helpers do
  def render_ad
    erb :partial_ad, layout: false
  end

  def render_job_posts
    erb :partial_jobpost, layout: false, locals: { jobs: Job.get_jobs }
  end

  def render_breadcrumb
    # interface: at controller like:
    # @breadcrumb = [
    #  { name: "首页", url: '/' },
    #  { name: "提问", active: true }
    # ]
    erb :partial_breadcrumb, layout: false
  end

  def render_login_modal
    # interface:
    # anchor or button with: data-toggle="modal" data-target="#login-modal"
    # can toggle this modal
    # using js: function login()
    erb :partial_login_modal, layout: false
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

  def render_alert_box
    # JS interface:
    # function show_alert(type, text)
    # type in ["info", "success", "danger", "warning"]
    erb :partial_alertbox, layout: false
  end
end
