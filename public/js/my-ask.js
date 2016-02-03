/*
  only used in /ask page
  ajax for title input and tags input
 */
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

function tag_sug_click(name) {
  $("div[class='bootstrap-tagsinput'] > input").val('');
  $("input[name='tagsinput']").tagsinput('add', name);
}

function tag_new_click(name) {
  $("#new-tag-name > span").text(name);
  $("#new-tag-modal").modal('show');
  $("#new-tag-desc > textarea").val('');
}

function new_tag() {
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
}
