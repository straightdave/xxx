/* only used in /ask page */
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
          var tagItems = "<li>\n";
          for(var i = 0; i < data.num; i++) {
            tagItems += "<a href='#'>" + ts[i].name + "</a>\n";
            tagItems += "</li>\n";
          }
          console.log(tagItems);
          $(pane).html(tagItems);
        }
        else {
          var createNewTag = "<li><a href='#'>创建标签" + keywords + "</a></li>";
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

  $("div[class='bootstrap-tagsinput'] > input").blur(function () {
    console.log("leave tag input");
    $(pane).hide();
  });
});
