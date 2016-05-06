/* xxx project copyrights 2015 Dave */
$().ready(function () {
  // own profile page
  $("button#resend").removeAttr("disabled");

  // tags-search and intag-search boxes' actions
  $("input.searchbox").keydown(function (event) {
    var keycode = (event.keyCode ? event.keyCode : event.which);
    if (keycode == '13') {
      keywords = $(this).val();
      target = $(this).attr("name");

      if (keywords.trim() == "") {
        location.replace(remove_param("q"));
        return;
      }
      keywords = keywords.replace(' ', '+');
      location.replace(add_only_param("q", keywords));
    }
  });
});

/* common functions */
function setCookie(c_name, value, expiredays) {
  var exdate = new Date();
  exdate.setDate(exdate.getDate() + expiredays);
  document.cookie = c_name + "=" + escape(value) +
    ((expiredays == null) ? "" : ";expires=" + exdate.toGMTString());
}
function getCookie(c_name) {
  if (document.cookie.length > 0) {
    c_start = document.cookie.indexOf(c_name + "=");
    if (c_start != -1) {
      c_start = c_start + c_name.length + 1;
      c_end = document.cookie.indexOf(";", c_start);
      if (c_end == -1) {
        c_end = document.cookie.length;
      }
      return unescape(document.cookie.substring(c_start, c_end));
    }
  }
  return "";
}

function hashCode(str) {
  var hash = 0, i, chr, len;
  if (str.length === 0) return hash;
  for (i = 0, len = str.length; i < len; i++) {
    chr   = str.charCodeAt(i);
    hash  = ((hash << 5) - hash) + chr;
    hash |= 0; // Convert to 32bit integer
  }
  return hash;
}

// remove or append div to show error messages
function clean_below_msg(obj) {
  $("div").remove("#msg-" + obj.attr("name"));
}
function show_below_msg(obj, text) {
  clean_below_msg(obj);
  obj.after("<div class='text-danger' id='msg-" + obj.attr("name") + "'>" + text + "</div>");
}

function getURLParameter(name) {
  return decodeURIComponent(
    (new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)')
      .exec(location.search) || [, ""]
    )[1].replace(/\+/g, '%20')
  ) || null;
}

// add/update param and value for CURRENT URL
function add_param(key, value) {
  var result = new RegExp(key + "=([^&]*)", "i").exec(location.search);
  result = (result && result[1]) || "";

  var url = location.pathname;
  if (result == '') {
    if (location.search == '') {
      url += "?" + key + '=' + value;
    }
    else {
      url += location.search + "&" + key + '=' + value;
    }
  }
  else {
    url += location.search.replace(key + "=" + result, key + "=" + value);
  }
  return url;
}

function add_only_param(key, value) {
  // set this param the only one in url.search
  return location.pathname + "?" + key + '=' + value;
}

function remove_param(key) {
  var result = new RegExp(key + "=([^&]*)", "i").exec(location.search);
  result = (result && result[1]) || "";

  if (result != '') {
    var new_search = location.search.replace(key + "=" + result, '');
    return location.pathname + new_search;
  }
  return location.pathname + location.search;
}

/* navbar input */
function widen_input(flag) {
  var input = $("input[name='q']");
  if (true == flag) {
    input.animate({ width : '+=200px'});
  }
  else {
    input.animate({ width : '-=200px'});
  }
}

/* ===== functions used for login/logout ===== */
function logout() {
  $.post('/logout', function() { location.replace('/'); });
}

/* ===== my message page ===== */
function mark_all_as_read() {
  $.post('/user/mark_messages', function (data, status) {
    if(data.ret == "success") {
      $("div.message").removeClass("unread");
      $("span.badge").hide();
      $("button#btn_mark").attr("disabled", "disabled");
    }
  });
}

/* common, used in login or some */
function set_normal(ele, eid) {
  ele.parent().removeClass("has-error");
  ele.parent().removeClass("has-success");
  $("span").remove("#" + eid);
}
function set_success(ele, eid) {
  set_normal(ele, eid);
  ele.parent().addClass("has-success");
  ele.parent().append("<span id='" + eid + "' class='glyphicon glyphicon-ok form-control-feedback' aria-hidden='true'></span>");
}
function set_error(ele, eid) {
  set_normal(ele, eid);
  ele.parent().addClass("has-error");
  ele.parent().append("<span id='" + eid +"' class='glyphicon glyphicon-remove form-control-feedback' aria-hidden='true'></span>");
}

/* question page */
function show_comment() {
  var cmt_area = $("div.commenting");
  cmt_area.slideDown();
}
function show_comment_answer(answer_id) {
  var cmt_area = $("div.commenting-answer-" + answer_id)
  cmt_area.slideDown();
}
function cancel_comment() {
  $("textarea#comment_area").val("");
  $("div.commenting").slideUp();
}
function cancel_comment_answer(answer_id) {
  $("textarea#comment_area_answer_" + answer_id).val("");
  $("div.commenting-answer-" + answer_id).slideUp();
}
function do_comment(qid) {
  var text = $("textarea#comment_area").val();
  if(text.length < 10) {
    alert("起码要多于10个字吧");
  }
  else {
    var data = { "content" : text };
    $.post("/q/" + qid +"/comment", data, function (data, status) {
      if(data.ret == "success") {
        location.replace(location.href);
      }
      else {
        if(data.msg == "need_login") {
          alert("请先登录");
        }
        else if (data.msg == "repu_cannot_comment") {
          alert("声誉超过10才可以评论呢");
        }
      }
    });
  }
}

function do_comment_answer(aid) {
  var text = $("textarea#comment_area_answer_" + aid).val();
  if(text.length < 10) {
    alert("起码要多于10个字吧");
  }
  else {
    var data = { "content" : text };
    $.post("/a/" + aid +"/comment", data, function (data, status) {
      if(data.ret == "success") {
        location.replace(location.href);
      }
      else {
        if(data.msg == "need_login") {
          alert("请先登录");
        }
      }
    });
  }
}

function vote(op_type, target_type, id) {
  // params:
  // op_type: 'vote' or 'devote'
  // target_type - target, 'q' for question, 'a' for answer, 'c' for comment
  // id - target id
  var url = "/" + target_type + "/" + id + "/" + op_type;
  $.post(url, function (data, status) {
    if(data.ret == "success") {
      $("span[id='"+ target_type +"-scores-" + id + "']").text(data.msg);
    }
    else {
      alert(data.msg);
    }
  });
}

// watch and unwatch are reserved words in js. so use append "1" here
// for watch1, it is a toggle action of the 'star' sign on the question page,
// which is both 'to watch' or 'unwatch'
function watch1(qid) {
  var icon = $("a#watchicon");

  if(icon.hasClass("watched")) {
    $.post("/q/" + qid + "/unwatch", function (data, status) {
      if(data.ret == "success") {
        icon.removeClass("watched");
        icon.attr("class", "watching");
        icon.attr("title", "点击收藏");
      }
      else {
        alert(data.msg);
      }
    });
  }
  else {
    $.post("/q/" + qid + "/watch", function (data, status) {
      if(data.ret == "success") {
        icon.attr("class", "watched");
        icon.attr("title", "已收藏");
      }
      else {
        alert(data.msg);
      }
    });
  }
}

function unwatch1(qid) {
  $.post("/q/" + qid + "/unwatch", function (data, status) {
    if(data.ret == "success") {
      location.replace(location.href);
    }
    else {
      alert(data.msg);
    }
  });
}

function do_answer(qid) {
  var text = CKEDITOR.instances.editor1.getData();
  if(text.length < 10) {
    alert("答案起码得超过10个字吧。");
  }
  else {
    var data = { "content" : text };
    $.post("/q/" + qid + "/answer", data, function (data, status) {
      if(data.ret == "success") {
        location.replace("/q/" + qid);
      }
      else {
        alert(data.msg);
      }
    });
  }
}

function toggle_comment(qid) {
  $.post('/q/' + qid + '/toggle_comment', {}, function (data, status) {
    if(data.ret == "success") {
      location.replace(location.href);
    }
    else {
      alert(data.msg);
    }
  });
}

/* tag links on homepage */
function go_tag(id) {
  location.replace("/t/" + id);
}

/* sns */
function do_follow(user) {
  $.post("/u/" + user + "/follow", function (data, status) {
    if(data.ret == "success") {
      /* if it becomes slow in the future,
      we can change elements without refreshing page */
      location.replace(location.href);
    }
    else {
      if(data.msg == "need_login") {
        alert("请先登录");
      }
    }
  });
}

function cancel_follow(user) {
  $.post("/u/" + user + "/unfollow", function (data, status) {
    if(data.ret == "success") {
      location.replace(location.href);
    }
  });
}

/* accept answer */
function mark_as_accepted(qid, aid) {
  var data = { "aid" : aid };
  $.post("/q/" + qid + "/accept", data, function (data, status) {
    if(data.ret == "success") {
      location.replace(location.href);
    }
  });
}

/* tags page, used for sort */
function sort_by(key) {
  location.replace(add_param('sort', key));
}
function pager_move(p) {
  location.replace(add_param('page', p));
}
function pager_slice(s) {
  location.replace(add_param('slice', s));
}

/* job posting */
function go_job(id) {
  location.replace('/job/' + id);
}

/* feedback */
function do_feedback() {
  var title = $("input[name='title']").val();
  var desc = CKEDITOR.instances.editor_fb.getData();

  $.post('/feedback', { "title" : title, "desc" : desc },
  function (data, status) {
    if (data.ret == "success") {
      alert("提交成功");
      location.replace('/');
    }
    else {
      var err_msg = data.msg;
      $("div#err_msg_fb").html(err_msg);
    }
  });
}

/* edit content */
function save_edit(strType, id) {
  if(strType == 'q') {
    var content = CKEDITOR.instances.editor2.getData();
    $.post('/q/' + id, { 'content' : content }, function (data, status) {
      if(data.ret == "success") {
        location.replace(location.href);
      }
      else {
        alert(data.msg);
      }
    });
  }
  else if (strType == 't') {
    var name = $("input[name='tagname']").val();
    var desc = $("textarea[name='tagdesc']").val();

    $.post('/t/' + id, { 'tname' : name, 'tdesc' : desc },
    function (data, status) {
      if(data.ret == "success") {
        location.replace(location.href);
      }
      else {
        alert(data.msg);
      }
    });
  }
}

/* refind */
function send_refind_email() {
  var email = $("input[name='email']").val();
  var name = $("input[name='name']").val();
  if(name.length > 0 && email.length > 0) {
    console.log("user input name: "  + name);
    console.log("user input email: " + email);

    $.post('/user/iforgot', { 'name' : name, 'email' : email }, function (data, status) {
      if(data.ret == "success") {
        alert("邮件已发送，请查收");
        location.replace("/");
      }
      else {
        alert(data.msg);
      }
    });
  }
}

function save_new_password() {
  var pass1 = $("input[name='new_pass1']").val();
  var pass2 = $("input[name='new_pass2']").val();
  if(pass1.length > 0 && pass2.length > 0) {
    console.log("user input pass1: " + pass1);
    console.log("user input pass2: " + pass2);

    if(pass1 != pass2) {
      alert("两次输入的不一致");
    }
    else {
      $.post('/user/reset_password', { 'pass1' : pass1, 'pass2' : pass2 },
      function (data, status) {
        if(data.ret == "success") {
          alert("密码重设成功");
          location.replace("/");
        }
        else {
          alert(data.msg);
        }
      });
    }
  }
}

/* draft page */
function delete_draft(id) {
  $.post('/draft/' + id + '/delete', function (data, status) {
    if(data.ret == "success") {
      location.replace(location.href);
    }
    else {
      alert(data.msg);
    }
  });
}

function resume_draft(id, draft_type) {
  if (window.localStorage) {
    window.localStorage.setItem("draft_id", id);
  }
  else {
    setCookie("draft_id", id, 1);
  }

  if (draft_type == 0) {
    location.replace('/ask');
  }
}
