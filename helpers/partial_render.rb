

helpers do
  def render_ad
    erb :partial_ad, layout: false
  end

  def render_job_posts
    # TODO: be careful!
    # now we don't have model: Job
    # do not use
    # --- 2016/4/26
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

  def render_tag_new_modal
    erb :partial_tag_new_modal, layout: false
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

  def render_foldable_header
    erb :partial_foldable_header, layout: false
  end

  def render_nav_tab
    # API:
    # @navbar_active
    # @navbar_hide_level: logo, all
    erb :partial_nav_tab, layout: false
  end

  def render_top_user
    erb :partial_top_user, layout: false
  end

  def render_question_list(type = :related)
    erb :partial_question_list, layout: false, locals: { question_type: type }
  end

  def render_tag_box(param = {})
    by_what = param[:by] || :hot
    amount = param[:sum] || 10

    tags = case by_what
    when :hot then
      Tag.top_used(amount)
    end
    erb :partial_tags, layout: false, locals: { tags: tags }
  end
end
