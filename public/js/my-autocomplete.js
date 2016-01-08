/* only used in /ask page */
$().ready(function () {
  $("input[name='title']").focus();

  var delay = (function(){
    var timer = 0;
    return function(callback, ms){
      clearTimeout (timer);
      timer = setTimeout(callback, ms);
    };
  })();

  $("input[name='title']").keyup(function (event) {
    var f1 = function () {
      var keywords = event.target.value;
      if ( keywords.trim().length < 2 ) return;

      // console.log("搜索类似题目：" + keywords);
      $.post('/search_title', { "q" : keywords }, function (data, status) {
        if (data.num > 0) {
          var qs = JSON.parse(data.data);
          var content = "<p>相似问题</p>\n";
          for(var i = 0; i < data.num; i++) {
            content += "<div class='linked-title'>\n";
            content += "<span>" + qs[i].views + "</span>"
            content += "<a href='/q/" + qs[i].id + "'>";
            content += (qs[i]).title;
            content += "</a>\n<div>\n"
          }
          $("div.similar-question-list").html(content);
          console.log(qs[0]);
        }
        else {
          console.log("Not found any");
        }
      });
    }
    delay(f1, 500);

  });






});
