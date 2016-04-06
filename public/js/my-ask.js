(function (window, $) {
  var is_ok_title = false,
      is_ok_text  = false;
  var btnDoAsk = $("button[name='btnDoAsk']");
  var titlebox = $("input[name='title']");
  var textbox  = $("input[id='editor1']").parent();

  var _do_ask = function () {
    clean_below_msg(titlebox);
    clean_below_msg(textbox);

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
    if (content.length < 10) {
      is_ok_text = false;
      set_error(textbox, 'text');
      show_below_msg(textbox, "内容不要少于10个字符");
    }
    if (content.length > 500) {
      is_ok_text = false;
      set_error(textbox, 'text');
      show_below_msg(textbox, "内容不要多于500个字符");
    }

    if(is_ok_title && is_ok_text) {
      clean_below_msg(btnDoAsk);
      var data = { "title" : title, "tags" : tag_v, "content" : content };
      $.post("/ask", data, function (data, status) {
        if(data.ret == "success"){
          location.href = "/q/" + data.msg;
        }
        else {
          if(data.msg == "need_login") {
            show_below_msg(btnDoAsk, "请先登录。一般不会看到这个错误，可能在您输入文字过程中丢失了登录状态");
          }
          else if(data.msg == "wrong_status") {
            show_below_msg(
              btnDoAsk,
              "您的状态无法提问哦。请先验证邮箱。如果没有收到验证邮件，可以去用户资料页面操作"
            );
          }
          else {
            show_below_msg(btnDoAsk, "遇到未知错误");
          }
        }
      });
    }
  };
  btnDoAsk.on('click.app', _do_ask);

  // functions dealing with tags
  var tag_sug_click = function (name) {
    $("div[class='bootstrap-tagsinput'] > input").val('');
    $("input[name='tagsinput']").tagsinput('add', name);
  };
  var tag_new_click = function (name) {
    $("#new-tag-name > span").text(name);
    $("#new-tag-modal").modal('show');
    $("#new-tag-desc > textarea").val('');
  };
  var new_tag = function () {
    var name = $("#new-tag-name > span").text();
    var desc = $("#new-tag-desc > textarea").val();
    console.log("name=" + name + ", desc= " + desc);
    if (name.trim() != '' && desc.trim() != '') {
      $.post('/tags/new', { "name": name, "desc": desc }, function (data, status) {
        if (data.ret == "success") {
          tag_sug_click(name);
          $("#new-tag-modal").modal('hide');
        }
        else if (data.msg == "wrong_status"){
          alert("你的状态不可以创建标签");
        }
        else if (data.msg == "lack_of_args"){
          alert("信息不完整");
        }
        else {
          alert("创建失败");
        }
      });
    }
  };


  // register some init ready functions
  $().ready(function () {
    $("input[name='title']").focus();

    // load common func
    var delay = (function(){
      var timer = 0;
      return function(callback, ms){
        clearTimeout (timer);
        timer = setTimeout(callback, ms);
      };
    })();

    // search similar questions via titles
    $("input[name='title']").keyup(function (event) {
      delay(function () {
        var keywords = event.target.value;
        if (keywords.trim().length < 2) return;

        $.post('/search_title', { "q" : keywords }, function (data, status) {
          if (data.num > 0) {
            var qs = JSON.parse(data.data);
            var content = "<p>相似问题</p>\n";
            for(var i = 0; i < data.num; i++) {
              content += "<div class='linked-title'>\n";
              content += "<span>" + qs[i].views + "</span>"
              content += "<a href='/q/" + qs[i].id + "'>";
              content += qs[i].title;
              content += "</a>\n<div>\n"
            }
            $("div.similar-question-list").html(content);
          }
          else {
            console.log("Not found any");
          }
        });
      }, 500);
    });

    // pop-up tag suggest
    var pane = document.getElementById("tag-suggest");
    $("div[class='bootstrap-tagsinput'] > input").keyup(function (event) {
      delay(function () {
        var keywords = event.target.value;
        if (keywords.trim().length < 2) return;

        $.post('/search_tag', { "q" : keywords }, function (data, status) {
          if (data.num > 0) {
            var ts = JSON.parse(data.data);
            var tagItems = "";
            var all_diff = true;
            for(var i = 0; i < data.num; i++) {
              tagItems += "<li>\n<a href='javascript:void(0);' onclick='tag_sug_click(\""+ ts[i].name +"\");'><span class='q_tag'>";
              tagItems += ts[i].name;
              tagItems += "</span> &times; ";
              tagItems += ts[i].used;
              tagItems += "</a>\n</li>\n";
              if (ts[i].name == keywords) {
                all_diff = false;
              }
            }
            if (all_diff) {
              tagItems += "<li role='separator' class='divider'></li>\n";
              tagItems += "<li><a href='javascript:void(0);' onclick='tag_new_click(\"" + keywords + "\");'>创建标签<span class='q_tag'>";
              tagItems += keywords;
              tagItems += "</span></a></li>\n";
            }
            $(pane).html(tagItems);
          }
          else {
            var createNewTag = "<li><a href='javascript:void(0);' onclick='tag_new_click(\"" + keywords + "\");'>创建标签<span class='q_tag'>";
            createNewTag += keywords;
            createNewTag += "</span></a></li>\n";
            $(pane).html(createNewTag);
          }
        });

        var x = $(event.target).offset().left;
        var y = $(event.target).offset().top;
        $(pane).css("top", y - 85);
        $(pane).css("left", x);
        $(pane).show();
      }, 500);
    });

    // close sug pane
    $("div[class='bootstrap-tagsinput'] > input").blur(function () {
      delay(function () {
        $(pane).hide();
      }, 500);
    });
  });
})(window, jQuery);
