/* xxx project copyrights 2015 Dave */
$().ready(function () {
  // sign in modal initialize
  $('#login-modal').on('show.bs.modal', function () {
    var namebox = $('input[name="modal-loginname"]');
    var passbox = $('input[name="modal-password"]');
    namebox.val(""); set_normal(namebox, "name");
    passbox.val(""); set_normal(passbox, "pass");
    $('#err-msg').text("");
  })

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

/* basic functions */
function add_param(key, value) {
  /* add/update param and value for CURRENT URL */

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
    input.attr("placeholder", "<ENTER 回车>键确认");
  }
  else {
    input.animate({ width : '-=200px'});
    input.attr("placeholder", "快速搜索");
  }
}


/* ===== functions used for login/logout ===== */
function login() {
  // login method 1: used in home page, modal window
  var is_valid = true;
  var u = $("input[name='modal-loginname']");
  var uv = u.val().trim();
  if (uv == "") {
    set_error(u, 'name');
    is_valid = false;
  } else { set_success(u, 'name'); }
  var p = $("input[name='modal-password']");
  var pv = p.val().trim();
  if (pv == "") {
    set_error(p, 'pass');
    is_valid = false;
  } else { set_success(p, 'pass'); }
  if (is_valid) {
    var data = {
      "login_name" : uv,
      "password"   : pv
    };
    $.post("/login", data, function(data, status) {
      if (data.ret == "success") {
        location.replace(location.href);
      }
      else {
        if(data.msg == "login_fail") {
          set_error(u, 'name');
          set_error(p, 'pass');
          $("#err-msg").text("用户名密码不正确");
        }
        else if(data.msg == "waiting") {
          $("#err-msg").text("由于错误次数过多，请等待一会儿再试");
        }
        else if(data.msg == "fail_5") {
          $("#err-msg").text("由于错误超过5次，请等待15秒再试");
        }
        else if(data.msg == "fail_10") {
          $("#err-msg").text("由于错误超过10次，请等待30秒再试");
        }
        else {
          $("#err-msg").text("未知错误");
        }
      }
    });
  }
}

function login2() {
  //login method 2: used in login page

  var is_valid = true;
  var ret_page = $("input[name='return_page']").val();
  ret_page = decodeURIComponent(ret_page);
  var name_input = $("input[id='u']");
  var name = name_input.val().trim();
  var reg=/^[0-9a-zA-Z_]{1,50}$/i;
  if (name == "" || !reg.test(name)) {
    set_error(name_input, 'name');
    $("#err-msg2").text("登录名为下划线、字母和数字的组合，不超过50个字符");
    is_valid = false;
  }
  else {
    set_success(name_input, 'name');
  }
  var pass_input = $("input[id='p']");
  var pass = pass_input.val().trim();
  if (pass == "") {
    set_error(pass_input, 'pass');
    is_valid = false;
  }
  else {
    set_success(pass_input, 'pass');
  }
  if (is_valid) {
    var data = {
      "login_name" : name,
      "password"   : pass
    };
    $.post("/login", data, function (data, status) {
      if(data.ret == "success") {
        if(data.msg == "admin") {
          location.replace(data.msg);
        }
        else {
          var return_url = ret_page || "/";
          location.replace(return_url);
        }
      }
      else {
        if(data.msg == "login_fail") {
          $("#err-msg2").text("");
          $("#err-msg2").append("登录名或密码错误。" +
            "忘记密码？<a href='/user/iforgot?u=" + name + "'>找回密码</a>");
        }
        else if(data.msg == "waiting") {
          $("#err-msg2").text("由于错误次数过多，请等待一会儿再试");
        }
        else if(data.msg == "fail_5") {
          $("#err-msg2").text("由于错误超过5次，请等待15秒再试");
        }
        else if(data.msg == "fail_10") {
          $("#err-msg2").text("由于错误超过10次，请等待30秒再试");
        }
        else {
          $("#err-msg2").text("未知错误");
        }
      }
    });
  }
}

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

/* ===== home page ===== */
function ask() {
  $.get("/check_login", function (data, status) {
    if(data.ret){
      location.href = "/ask";
    }
    else {
      location.href = "/login?r=" + encodeURIComponent("/ask");
    }
  });
}

/* ===== ask page ===== */
function do_ask() {
  var is_valid = true;
  var err_msg = "";
  var t = $("input[name='title']");
  var tt = t.val().trim();
  if(tt == "") {
    set_error(t, 'title');
    err_msg += "请输入标题 &nbsp; ";
    is_valid = false;
  }
  var tag_v = $("input[name='tagsinput']").val();
  var content = CKEDITOR.instances.editor1.getData();
  // remove the last div of the content
  // which could be added by any browser plugin
  //var div_pos = content.lastIndexOf('<div');
  //content = content.substring(0, div_pos);
  if (content.length < 10) {
    set_error($("textarea#editor1"), 'content');
    err_msg += "字数太少了吧 &nbsp; ";
    is_valid = false;
  }
  if (content.length > 500) {
    err_msg += "字数太多了 &nbsp; ";
    is_valid = false;
  }
  if(is_valid) {
    var data = { "title" : tt, "tags" : tag_v, "content" : content };
    $.post("/ask", data, function (data, status) {
      if(data.ret == "success"){
        location.href = "/q/" + data.msg;
      }
      else {
        if(data.msg == "need_login") {
          alert("请先登录");
        }
        else if(data.msg == "wrong_status") {
          alert("您的状态无法提问哦。请先验证邮箱。如果没有收到验证邮件，可以去 -更新资料- 页面操作。");
        }
      }
    });
  } else { $("#err_msg_ask").html(err_msg); }
}

/* used in login or some */
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
      if(data.msg == "need_login") {
        alert("请先登录");
      }
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

/* update own profile page */
function do_avatar_change() {
  $("form#avatar-form").submit();
}

/* update user's profile */
function do_update() {
  var nickname = $("input[name='nickname']").val();
  var intro    = $("input[name='intro']").val();
  var phone    = $("input[name='phone']").val();
  var city     = $("input[name='city']").val();
  var qq       = $("input[name='qq']").val();
  var wechat   = $("input[name='wechat']").val();
  var email2   = $("input[name='email2']").val();
  var email    = $("input[name='email']").val();

  var data = {
    "nickname" : nickname,
    "intro" : intro,
    "phone" : phone,
    "city" : city,
    "qq" : qq,
    "wechat" : wechat,
    "email2" : email2,
    "email" : email
  };

  $.post("/user/profile", data, function (data, status) {
    if(data.ret == "success") {
      location.replace(location.href);
    }
    else {
      if(data.msg == "cannot_change_email") {
        alert("您当前的状态不可以变更邮箱哦")
      }
    }
  });
}

/* sns */
function do_follow(user) {
  $.post("/u/" + user + "/follow", function (data, status) {
    if(data.ret == "success") {
      /* if it becomes slow in the future, we can change elements without refreshing page */
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

/* own prifle page */
function resend_validation() {
  var button = $("button#resend");
  button.attr("disabled", "disabled");
  var origin_text = button.text();
  var ticks = 15;
  button.text(ticks + "秒后再次发送");
  $.post("/user/send_validation", function (data, status) {
    if (data.ret == "error") {
      if (data.msg == "resend_too_frequent") {
        alert("发送过于频繁，请稍候重试");
      }
      else {
        alert("发送失败，可能是系统故障，请稍候重试");
      }
    }
    var clock = setInterval(function () {
      ticks--;
      button.text(ticks + "秒后再次发送");
      if (ticks == 0) {
        clearInterval(clock);
        button.text(origin_text);
        button.removeAttr("disabled");
      }
    }, 1000);
  });
}

/* job posting */
function go_job(id) {
  location.replace('/job/' + id);
}

/* feedback */
function do_feedback() {
  var title = $("input[name='title']").val();
  var desc = CKEDITOR.instances.editor_fb.getData();

  $.post('/feedback', { "title" : title, "desc" : desc }, function (data, status) {
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

/* report */
function new_report(type, id) {
  var err_box = $("#report-err-msg");
  var reason = $("textarea[name='reason']").val();
  if (reason.length < 10) {
    err_box.html("不能少于10个字");
  }
  else {
    var post_data = { "target_type" : type, "target_id" : id, "content" : reason };
    $.post('/report', post_data, function (data, status) {
      if (data.ret == "success") {
        location.replace(location.href);
      }
      else {
        err_box.html(data.msg);
      }
    });
  }
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

    $.post('/t/' + id, { 'tname' : name, 'tdesc' : desc }, function (data, status) {
      if(data.ret == "success") {
        location.replace(location.href);
      }
      else {
        alert(data.msg);
      }
    });
  }
}
