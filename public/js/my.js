/* xxx project copyrights 2015-10 Dave */

// for all pages' onReady actions
$().ready(function () {
  switch(location.pathname) {
    case "/ask": {
      $("input[name='title']").focus();
      break;
    }
  }
});

/* login methods */
/* login method 1: used in home page, prompt window */
function login() {
  var is_valid = true;
  var u = $("input[name='login_name']");
  var uv = u.val().trim();
  if (uv == "") {
    set_error(u, "请输入用户名");
    is_valid = false;
  } else { set_ok(u); }
  var p = $("input[name='password']");
  var pv = p.val().trim();
  if (pv == "") {
    set_error(p, "请输入密码");
    is_valid = false;
  } else { set_ok(p); }
  if (is_valid) {
    var rm = $("input[name='rememberme']").prop("checked");
    var data = {
      "login_name" : uv,
      "password" : pv,
      "rememberme" : rm
    };
    $.post("/login", data, function(d, status) {
      if (d.ret == "success") {
        location.replace(location.href);
      }
      else {
        if(d.msg == "login_fail") {
          set_error(u);
          set_error(p);
          $("#err-msg").text("用户名密码不正确");
        }
        else if(d.msg == "waiting") {
          $("#err-msg").text("由于错误次数过多，请等待一会儿再试");
        }
        else if(d.msg == "fail_5") {
          $("#err-msg").text("由于错误超过5次，请等待15秒再试");
        }
        else if(d.msg == "fail_10") {
          $("#err-msg").text("由于错误超过10次，请等待30秒再试");
        }
        else {
          $("#err-msg").text("未知错误");
        }
      }
    });
  }
}

/* login method 2: used in login page */
function login2() {
  var is_valid = true;
  var name_input = $("input[id='u']");
  var name = name_input.val().trim();
  var reg=/^[0-9a-zA-Z_]{1,50}$/i;
  if (name == "" || !reg.test(name)) {
    set_error(name_input, "登录名非法");
    $("#err-msg2").text("登录名为下划线、字母和数字的组合，不超过50个字符");
    is_valid = false;
  }
  else {
    set_ok(name_input);
  }
  var pass_input = $("input[id='p']");
  var pass = pass_input.val().trim();
  if (pass == "") {
    set_error(pass_input, "请填写密码");
    is_valid = false;
  }
  else {
    set_ok(pass_input);
  }
  var remember = $("input[id='r2']").prop("checked");
  if (is_valid) {
    var data = {
      "login_name" : name,
      "password" : pass,
      "rememberme" : remember
    };
    $.post("/login", data, function (data, status) {
      if(data.ret == "success") {
        var return_url = GetUrlParam("returnurl") || "/";
        location.replace(return_url);
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
  $.post('/logout', function() {location.replace('/')});
}

/* for messages page */
function mark_all_as_read() {
  $.post('/user/mark_messages', function (data, status) {
    if(data.ret == "success") {
      $("div.message").removeClass("unread");
      $("span.badge").hide();
      $("button#btn_mark").attr("disabled", "disabled");
    }
  });
}

/* ask on homepage */
function ask() {
  $.get("/check_login", function (data,s) {
    if(data.ret){
      location.href = "/ask";
    } else {
      location.href = "/login";
    }
  });
}

function do_ask() {
  var is_valid = true;
  var err_msg = "";
  var t = $("input[name='title']");
  var tt = t.val().trim();
  if(tt == "") { set_error(t); err_msg += "请输入标题 &nbsp; "; is_valid = false; }
  var tags = $("input[name='tagsinput']");
  var tag_v = tags.val();
  var content = CKEDITOR.instances.editor1.getData();
  // remove the last div of the content
  // which could be added by any browser plugin
  //var div_pos = content.lastIndexOf('<div');
  //content = content.substring(0, div_pos);
  if(content.length < 10) {
    alert(content);
    set_error($("textarea#editor1"));
    err_msg += "字数太少了吧 &nbsp; ";
    is_valid = false;
  }
  if(is_valid) {
    var data = { "title" : tt, "tags" : tag_v, "content" : content };
    $.post("/ask", data, function (data, status) {
      if(data.ret == "success"){
        location.href = "/q/" + data.msg;
      }
      else {
        alert(data.msg);
      }
    });
  } else { $("#err_msg_ask").html(err_msg); }
}

/* used in login or some */
function set_ok(item) {
  item.parent().removeClass("has-error");
}

function set_error(item, msg) {
  item.parent().addClass("has-error");
  item.attr('placeholder', msg);
}

/* register */
function GetUrlParam(name) {
  var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)","i");
  var r = window.location.search.substr(1).match(reg);
  if (r!=null) return (r[2]); return null;
}

function do_register() {
  var is_valid = true;
  var name_input = $("input[id='lu']");
  var name = name_input.val().trim();
  var reg=/^[a-zA-Z0-9_]{1,50}$/i;
  if (name == "" || !reg.test(name)) {
    set_error(name_input, name);
    $("#err-msg2").text("英文字母，数字和下划线的组合，不超过50个字符");
    is_valid = false;
  }
  else {
    set_ok(name_input);
  }
  var pass_input = $("input[id='p1']");
  var pass = pass_input.val().trim();
  if (pass == "" || pass.length < 6) {
    set_error(pass_input);
    $("#err-msg2").text("请填写6位或以上字符密码");
    is_valid = false;
  }
  else {
    set_ok(pass_input);
  }
  var pass_again_input = $("input[id='p2']");
  var pass_again = pass_again_input.val().trim();
  if (pass_again != pass) {
    set_error(pass_again_input, "密码不一致");
    is_valid = false;
  }
  else {
    set_ok(pass_again_input);
  }
  var is_confirmed = $("input[name='confirmed']").prop("checked");
  if (!is_confirmed) { $("#err-msg2").text("请阅读并同意我们的条款 :-)"); }
  if (is_valid && is_confirmed) {
    var data = {
      "login_name" : name,
      "password" : pass,
      "password_again" : pass_again,
      "confirmed" : is_confirmed
    };
    $.post("/user/register", data, function (data, status) {
      if(data.ret == "error"){
        switch(data.msg) {
          case "login_info_err":
            $("#err-msg2").text("注册信息有误");
            break;
          case "name_exist":
            // walk around to put html element in text
            $("#err-msg2").text("");
            $("#err-msg2").append("该登录名已被使用，可尝试 <a href='/login?u="+ name +"'>登录</a>");
            break;
          default:
            $("#err-msg2").text(data.msg);
        }
      }
      else if(data.ret == "success") {
        var return_url = GetUrlParam("returnurl") || "/";
        location.replace(return_url);
      }
    });
  }
}

/* question page */
function show_comment() {
  $("div.commenting").slideDown();
}

function show_comment_answer(answer_id) {
  $("div.commenting-answer-" + answer_id).slideDown();
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
    alert("no less than 10 char");
  }
  else {
    var data = { "content" : text };
    $.post("/q/" + qid +"/comment", data, function (data, status) {
      if(data.ret == "success") {
        location.replace(location.href);
      }
      else {
        alert(data.msg);
      }
    });
  }
}

function do_comment_answer(aid) {
  var text = $("textarea#comment_area_answer_" + aid).val();
  if(text.length < 10) {
    alert("no less than 10 char");
  }
  else {
    var data = { "content" : text };
    $.post("/a/" + aid +"/comment", data, function (data, status) {
      if(data.ret == "success") {
        location.replace(location.href);
      }
      else {
        alert(data.msg);
      }
    });
  }
}

function vote(op, tar, id) {
  // params:
  // op - 0 means +1 (vote one point); 1 means -1 (devote)
  // tar - target, 'q' for question, 'a' for answer, 'c' for comment
  // id - target id

  var data = { "op" : (op == 1 ? "d" : "u") };  // d for downer, u for upper
  var url = "/" + tar + "/" + id + "/vote";
  $.post(url, data, function (data, status) {
    if(data.ret == "success") {
      $("span[id='"+ tar +"-scores-" + id + "']").text(data.msg);
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
    alert(text + " >> no less than 10 char");
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

/* tag links on homepage */
function go_tag(id) {
  location.replace("/t/" + id);
}

/* update own profile page */
function do_avatar_change() {
  // validate input file

  $("form#avatar-form").submit();
}

function do_update() {
  var nickname = $("input[name='nickname']").val();
  var intro = $("input[name='intro']").val();
  var email = $("input[name='email']").val();
  var contact = $("input[name='contact']").val();
  var city = $("input[name='city']").val();
  // validate things ...

  var data = {
    "nickname" : nickname,
    "intro" : intro,
    "email" : email,
    "contact" : contact,
    "city" : city
  };

  $.post("/user/profile", data, function (data, status) {
    if(data.ret == "success") {
      location.replace(location.href);
    }
  });
}

/* sns */
function do_follow(user) {
  $.post("/u/" + user + "/follow", function (data, status) {
    if(data.ret == "success") {
      location.replace(location.href);
    }
    else {
      alert(data.msg);
    }
  });
}

function cancel_follow(user) {
  $.post("/u/" + user + "/unfollow", function (data, status) {
    if(data.ret == "success") {
      location.replace(location.href);
    }
    else {
      alert(data.msg);
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
