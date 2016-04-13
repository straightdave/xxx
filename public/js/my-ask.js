// used in ask page ONLY
(function (window, $) {

  var do_ask = function () {
    var is_ok_title = false,
        is_ok_text  = false,
        btnDoAsk  = $("button[name='btnDoAsk']"),
        editorbox = $("div#editor-box"),
        tagsbox   = $("input[name='tagsinput']"),
        titlebox  = $("input[name='title']");

    clean_below_msg(titlebox);
    clean_below_msg(editorbox);

    var title = titlebox.val().trim();
    if (title.length < 6) {
      is_ok_title = false;
      set_error(titlebox, 'title');
      show_below_msg(titlebox, "标题不要少于6个字符");
    }
    else {
      is_ok_title = true;
      set_normal(titlebox, 'title');
      clean_below_msg(titlebox);
    }

    var tag_v = tagsbox.val();

    var content = CKEDITOR.instances.editor1.getData();
    if (content.length < 10 || content.length > 500) {
      is_ok_text = false;
      set_error(editorbox, 'text');
      show_below_msg(editorbox, "内容为 10 ~ 500 个字符");
    }
    else {
      is_ok_text = true;
      set_normal(editorbox, 'text');
      clean_below_msg(editorbox);
    }

    if(is_ok_title && is_ok_text) {
      clean_below_msg(btnDoAsk);
      var data = { "title" : title, "tags" : tag_v, "content" : content };
      $.post("/ask", data, function (data, status) {
        if(data.ret == "success")
          location.href = "/q/" + data.msg;
        else
          show_below_msg(btnDoAsk, data.msg);
      });
    }
  };

  var delay = (function(){
    var timer = 0;
    return function(callback, ms){
      clearTimeout (timer);
      timer = setTimeout(callback, ms);
    };
  })();

  var titlebox_keyup = function (event) {
    var title = $(this).val().trim();
    if (title.length < 2) {
      return;
    }

    delay(function () {
      $.post('/search_title', { "q" : title }, function (data, status) {
        if (data.num > 0) {
          var qs = JSON.parse(data.data);

          var content = "<p>相似问题</p>";
          for(var i = 0; i < qs.length; i++) {
            content += "<div class='linked-title'>";
            content += "  <span>" + qs[i].views + "</span>";
            content += "  <a href='/q/" + qs[i].id + "'>" + qs[i].title + "</a>";
            content += "<div>";
          }
          $("div.similar-question-list").html(content);
        }
        else {
          $("div.similar-question-list").html('');
          console.log("没有找到相似问题 for " + title);
        }
      });
    }, 300);
  };

  // document ready handler
  $(function () {
    var btnDoAsk  = $("button[name='btnDoAsk']"),  // final submit button
        titlebox  = $("input[name='title']");   // textarea container div

    titlebox.focus();
    titlebox.keyup(titlebox_keyup);
    btnDoAsk.click(do_ask);

    // bind keyup and blur event handler to other dynamic elements
    $("div[class='bootstrap-tagsinput']").on('keyup', "input", function (event) {
      event.preventDefault();

      var tag_input = $(this);
      var tag_name = tag_input.val();
      if (tag_name.length < 2) {
        return;
      }

      $.post('/tag/search', { "q" : tag_name }, function (data, status) {
        if (data.num > 0) {
          var ts = JSON.parse(data.data);

          var tagItems = "";
          var all_diff = true;
          for(var i = 0; i < data.num; i++) {
            tagItems += "<li><a name='"+ ts[i].name +"' class='sug-tag'>";
            tagItems += "<span class='q_tag'>" + ts[i].name;
            tagItems += "</span> &times;" + ts[i].used + "</a></li>";

            if (ts[i].name == tag_name) {
              all_diff = false;
            }
          }
          if (all_diff) {
            tagItems += "<li role='separator' class='divider'></li>";
            tagItems += "<li><a name='" + tag_name + "' class='new-tag'>";
            tagItems += "创建标签<span class='q_tag'>";
            tagItems += tag_name + "</span></a></li>";
          }
          $("ul#tag-suggest").html(tagItems);
        }
        else {
          var createNewTag = "<li><a name='" + tag_name + "' class='new-tag'>";
          createNewTag += "创建标签<span class='q_tag'>";
          createNewTag += tag_name + "</span></a></li>";
          $("ul#tag-suggest").html(createNewTag);
        }
        var top = $("div[class='bootstrap-tagsinput'] > input").offset().top;
        var left = $("div[class='bootstrap-tagsinput'] > input").offset().left;
        $("ul#tag-suggest").css({"top" : 120, "left" : left - 50}).show();
      });
    });

    // clean manual input letters and add chosen tag into tagsinput object
    $("ul#tag-suggest").on("click", "li > a[class='sug-tag']", function (event) {
      event.preventDefault();
      $("div[class='bootstrap-tagsinput'] > input").val('');
      $("input[name='tagsinput']").tagsinput('add', $(this).attr('name')); // add this tag
    });

    // pop-up and init the create-new-tag modal
    $("ul#tag-suggest").on("click", "li > a[class='new-tag']", function (event) {
      event.preventDefault();
      $("#new-tag-modal").modal('show');
      $("#new-tag-name > span").text($(this).attr('name'));
      $("#new-tag-desc > textarea").val('');
    });

    // delegation for tag input blur: hide tag-suggest drop-down menu
    $("div[class='bootstrap-tagsinput']").on('blur', "input", function (event) {
      delay(function () {
        $("ul#tag-suggest").hide();
      }, 200);
    });

  });
})(window, jQuery);
