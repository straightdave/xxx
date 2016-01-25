$().ready(function () {
  // init tooltips
  $('[data-toggle="tooltip"]').tooltip( { container : 'body'});

  $("input[name='login_name']").blur(function (event) {
    var target = $(event.target);
    var login_name = target.val().trim();
    if (login_name.length >= 3 && login_name.length <= 15) {
      $.post('/user/check/' + login_name, function (data, status) {
        if (data.ret == "success") {
          set_success(target, 'name');
        }
        else {
          set_error(target, 'name');
        }
      });
    }
  });
});

function do_register() {
  var is_valid = true;
  var err_msg = "";
  var name_input = $("input[id='name']");
  var name = name_input.val().trim();
  var reg= /^[a-zA-Z0-9_]{3,15}$/i;

  if (name == "" || !reg.test(name)) {
    set_error(name_input, 'name');
    err_msg += "账号是英文字母、数字和下划线的组合，3~15个字符。";
    is_valid = false;
  }

  var pass_input = $("input[id='password']");
  var pass = pass_input.val().trim();
  if (pass == "" || pass.length < 6 || pass.length > 20) {
    set_error(pass_input, 'pass');
    err_msg += "请填写6~20位字符的密码。";
    is_valid = false;
  }
  else {
    set_success(pass_input, 'pass');
  }

  var email_input = $("input[id='email']");
  var email = email_input.val().trim();
  var reg_email = /^[a-z0-9_\.-]+@[\da-z\.-]+\.[a-z\.]{2,6}$/i;
  if (email == "" || !reg_email.test(email)) {
    set_error(email_input, 'email');
    err_msg += "请合法的电子邮箱地址。";
    is_valid = false;
  }
  else {
    set_success(email_input, 'email');
  }

  var is_confirmed = $("input[name='confirmed']").prop("checked");
  if (!is_confirmed) {
    err_msg += "请阅读并同意我们的条款 :-)";
    is_valid = false;
  }

  var nickname = $("input[id='nickname']").val().trim();

  if (is_valid) {
    var data = {
      "login_name" : name,
      "password"   : pass,
      "nickname"   : nickname,
      "email"      : email
    };
    $.post("/user/register", data, function (data, status) {
      if(data.ret == "error"){
        switch(data.msg) {
          case "name_exist":
            $("#register-err-msg").text("");
            $("#register-err-msg").append(
              "该登录名已被使用，可尝试 <a href='/login?u=" + name + "'>登录</a>");
            break;
          case "model_invalid":
            alert("用户信息有误，保存失败");
            break;
          default:
            alert("系统错误，注册失败");
        }
      }
      else if(data.ret == "success") {
        location.replace("/");
      }
    });
  }
  else {
    $("#register-err-msg").text(err_msg);
  }
}
