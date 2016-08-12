(function (window, $) {
  /* used in ask page only */
  var submit_question = function (html_content) {
    var _titleBox  = $("input[name='title']"),
        _tagsBox   = $("input[name='tagsinput']"),
        _editorBox = $("div#ask-editor-box"),
        _submitBtn = $("button[name='btn_submit']");

    clean_below_msg(_titleBox);
    clean_below_msg(_editorBox);

    var title = _titleBox.val().trim();
    if (title.length < 6 || title.length > 50) {
      set_error(_titleBox);
      show_below_msg(_titleBox, "标题不要少于6个或多于50个字符");
      return;
    }
    else {
      set_normal(_titleBox);
      clean_below_msg(_titleBox);
    }

    var tag_v = _tagsBox.val();

    if (html_content.length < 10 || html_content.length > 500) {
      set_error(_editorBox);
      show_below_msg(_editorBox, "内容为 10 ~ 500 个字符");
      return;
    }
    else {
      set_normal(_editorBox);
      clean_below_msg(_editorBox);
    }

    clean_below_msg(_submitBtn);
    var data = { "title" : title, "tags" : tag_v, "content" : html_content };
    $.post("/ask", data, function (data, status) {
      if(data.ret == "success") { location.href = "/q/" + data.msg; }
      else { show_below_msg(_submitBtn, data.msg); }
    });
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
    if (title.length < 3) { return; }
    var root_ul = $("ul#_ul_similar_to_ask");

    delay(function () {
      $.post('/search_title', { "q" : title }, function (data, status) {
        if (data.num > 0) {
          var qs = JSON.parse(data.data);

          root_ul.empty();
          for(var i = 0; i < qs.length; i++) {
            var item = qs[i];

            var span_class;
            if (item.has_acc) { span_class = "list-vote-box-acc"; }
            else { span_class = "list-vote-box-nor"; }
            var tmp = "\
            <li>\
              <span class='" + span_class + "'>" + item.votes + "</span>\
              <a class='list-title' href='/q/" + item.id + "'>" +
                item.title +
              "</a>\
              <div class='clear'></div>\
            </li>";
            root_ul.append(tmp);
          }
        }
        else { console.log("没有找到相似问题 for " + title); }
      });
    }, 300);
  };

  // start of document ready event dealer
  $(function () {
    var _titleBox  = $("input[name='title']"),
        _tagsBox   = $("input[name='tagsinput']"),
        _editorBox = $("div#ask-editor-box"),
        _submitBtn = $("button[name='btn_submit']"),
        _saveDraftBtn = $("button[name='btn_save_draft']");

    _submitBtn.attr("disabled", "disabled");
    _saveDraftBtn.attr("disabled", "disabled");

    // init editor
    // this mean every time this page renders (including refresh),
    // the editor instance is initialized, losing every content
    var editor = new wangEditor('ask-editor-box');
    editor.config.menus = [
      'bold','underline','italic','strikethrough','eraser','forecolor','|',
      'quote','fontfamily','fontsize','unorderlist','orderlist','|',
      'link','unlink','table','emotion','img','|',
      'undo','redo','fullscreen'
    ];
    editor.config.uploadImgUrl = '/uploadeditor';
    editor.config.uploadImgFileName = 'uploadedimage';
    editor.config.hideLinkImg = true;
    editor.onchange = function () {
      var text_len = this.$txt.text().length;
      if (text_len > 0) {
        _submitBtn.removeAttr("disabled");
        _saveDraftBtn.removeAttr("disabled");
      }
      else {
        _submitBtn.attr("disabled", "disabled");
      }
    }
    editor.create();

    // bind submit action
    $("button[name='btn_submit']").click(function () {
        submit_question(editor.$txt.html());
    });

    // load draft to textboxes and editors
    var draft_id_to_load = -1;
    if (window.localStorage && window.localStorage["draft_id"]) {
      draft_id_to_load = window.localStorage["draft_id"];
      window.localStorage.removeItem("draft_id"); // clean draft id in storage
      console.log("load draft id: " + draft_id_to_load + " from localStorage");
    }
    else {
      draft_id_to_load = getCookie("draft_id");
      draft_id_to_load = parseInt(draft_id_to_load);
      setCookie("draft_id", "-1", 1); // clean draft id in cookie (set to -1)
      console.log("load draft id " + draft_id_to_load + " from cookie");
    }

    if (draft_id_to_load > 0) {
      $.get('/draft/' + draft_id_to_load, function (data, status) {
        if (data.ret == "success") {
          console.log("load draft by id: " + draft_id_to_load);

          var draft_obj = JSON.parse(data.content);
          _titleBox.val(draft_obj.title);
          _tagsBox.tagsinput("add", draft_obj.tags);

          // we already has editor instance, so set editor content with draft
          editor.$txt.html(draft_obj.content);
          console.log("draft loaded successfully");
        }
        else {
          console.log("server return draft failed: " + data.msg);
        }
      });
    }
    else {
      console.log("no draft to load");
      _titleBox.focus();
    }

    // bind title keyup action (finding similar titles)
    _titleBox.keyup(titlebox_keyup);

    // bind draft saving button click event
    _saveDraftBtn.click(function () {
      var title = _titleBox.val().trim();
      var tag_v = _tagsBox.val();
      var content = editor.$txt.html();
      var data = { "title" : title, "tags" : tag_v, "content" : content };
      var data_str = JSON.stringify(data);
      var hash_code = hashCode(data_str);
      var old_hash = "";
      if (window.localStorage && window.localStorage["draft_print"]) {
        old_hash = window.localStorage["draft_print"];
        console.log("saving draft: stored hash in localStorage");
      }
      else {
        old_hash = getCookie("draft_print");
      }
      if (old_hash == hash_code) {
        console.log("same with last hash, no need to save");
        _saveDraftBtn.attr("disabled", "disabled");
        return;
      }

      $.post('/draft', { title: title, type: 'question', data: data_str },
        function (data, status) {
          if (data.ret == "success") {
            _saveDraftBtn.attr("disabled", "disabled");
            if (window.localStorage) {
              window.localStorage["draft_print"] = hash_code;
            }
            setCookie("draft_print", hash_code, 1);
            console.log("draft saved. hash code: " + hash_code);
          }
          else {
            console.log("server saving draft failed: " + data.msg);
          }
        }
      );
    });

    // bind keyup and blur event handler
    // go server to find similar tags that already exist as suggestions
    $("div[class='bootstrap-tagsinput']").on('keyup', "input", function (event) {
      event.preventDefault();
      var tag_input = $(this);
      var tag_name = tag_input.val();
      if (tag_name.length < 2) { return; }

      $.post('/tag/search', {"q" : tag_name}, function (data, status) {
        if (data.num > 0) {
          var ts = JSON.parse(data.data);
          var tagItems = "";
          var all_diff = true;
          for(var i = 0; i < data.num; i++) {
            tagItems += "<li><a name='"+ ts[i].name +"' class='sug-tag'>";
            tagItems += "<span class='q_tag'>" + ts[i].name;
            tagItems += "</span> &times;" + ts[i].used + "</a></li>";

            if (ts[i].name == tag_name) { all_diff = false; }
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
        $("ul#tag-suggest").css({"top" : 90, "left" : left - 130 }).show();
      });
    });

    // if input some characters for tag, then refreshing page without hitting enter
    // so some letters would remain there in the tagsinput box
    // code here cleans manual input letters and add chosen tag into tagsinput object
    // - it breaks into tagsinput.js and use jQuery delegation
    $("ul#tag-suggest").on("click", "li > a[class='sug-tag']", function (event) {
      event.preventDefault();
      $("div[class='bootstrap-tagsinput'] > input").val('');
      $("input[name='tagsinput']").tagsinput('add', $(this).attr('name')); // add this tag
    });

    // providing a jQuery delegation to pop-up and init the create-new-tag modal
    // - similarly, it breaks into tagsinput.js
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
  }); // end of document.ready
})(window, jQuery);
