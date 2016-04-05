(function(window, $) {
  // page global variables
  var is_ok_name = false;
  var is_ok_email = false;
  var is_ok_password = false;
  var is_ok_terms = true;
  var _login_name, _email, _password;
  var btnSubmit = $('#check-captcha-filled');

  // remove or append div to show error messages
  var clean_below_msg = function (obj) {
    $("div").remove("#msg-" + obj.attr("name"));
  };
  var show_below_msg = function (obj, text) {
    clean_below_msg(obj);
    obj.after("<div class='text-danger' id='msg-" + obj.attr("name") + "'>" + text + "</div>");
  };

  // check fields
  var check_name = function () {
    var target = $("input[name='login_name']");
    _login_name = target.val().trim();
    var reg= /^[a-zA-Z0-9_]{3,15}$/i;
    if (!reg.test(_login_name)) {
      is_ok_name = false;
      set_error(target, 'name');
      show_below_msg(target, "账号是英文字母、数字和下划线的组合，3~15个字符");
    }
    else {
      $.post('/user/check_name/' + _login_name, function (data, status) {
        if (data.ret == "success") {
          is_ok_name = true;
          set_success(target, 'name');
          clean_below_msg(target);
        }
        else {
          is_ok_name = false;
          set_error(target, 'name');
          show_below_msg(target, "该登录名已被使用，可尝试 <a href='/login?u=" + _login_name + "'>登录</a>");
        }
      });
    }
  };

  var check_email = function () {
    var target = $("input[name='email']");
    _email  = target.val().trim();
    var reg_email = /^[a-z0-9_\.-]+@[\da-z\.-]+\.[a-z\.]{2,6}$/i;
    if (!reg_email.test(_email)) {
      is_ok_email = false;
      set_error(target, 'email');
      show_below_msg(target, "请合法的电子邮箱地址");
    }
    else {
      $.post('/user/check_email/' + _email, function (data, status) {
        if (data.ret == "success") {
          is_ok_email = true;
          set_success(target, 'email');
          clean_below_msg(target);
        }
        else {
          is_ok_email = false;
          set_error(target, 'email');
          show_below_msg(target, "该邮箱已被使用");
        }
      });
    }
  };

  var check_password = function () {
    var target = $("input[name='password']");
    _password  = target.val().trim();
    if (_password.length < 6 || _password.length > 20) {
      is_ok_password = false;
      set_error(target, 'pass');
      show_below_msg(target, "请填写6~20位字符的密码");
    }
    else {
      is_ok_password = true;
      set_success(target, 'pass');
      clean_below_msg(target);
    }
  };

  var check_terms = function () {
    var terms_box = $("input[name='terms-accepted']");
    var is_terms_accepted = terms_box.prop("checked");
    if (!is_terms_accepted) {
      is_ok_terms = false;
      show_below_msg(btnSubmit, "请阅读并同意我们的条款 :-)");
    }
  };

  // do signup after captcha filled
  var do_signup = function () {
    check_name();
    check_email();
    check_password();
    check_terms();

    var preCheckOk = is_ok_name && is_ok_email && is_ok_password && is_ok_terms;
    var nickname = $("input[name='nickname']").val().trim();
    if (preCheckOk) {
      var data = {
        "login_name" : _login_name,
        "password"   : _password,
        "nickname"   : nickname,
        "email"      : _email
      };

      $.post("/user/signup", data, function (data, status) {
        if(data.ret == "error"){
          switch(data.msg) {
            case "name_exist":
              show_alert("info", "该登录名已被使用，可尝试 <a href='/login?u=" + _login_name + "'>登录</a>");
              break;
            case "email_exist":
              show_alert("info", "该邮箱已被使用");
              break;
            case "model_invalid":
              show_alert("danger", "用户信息有误，保存失败");
              break;
            default:
              show_alert("danger", "系统错误，注册失败");
          }
        }
        else {
          var return_url = getURLParameter("returnurl");
          if(return_url != null) {
            location.replace(return_url);
          }
          else {
            location.replace("/");
          }
        }
      });
    }
  };

  // register page init actions
  $(function() {
    // init and show mycaptcha
    var captchaEl = $("div#mycaptcha").visualCaptcha({
      imgPath: '/images/',
      captcha: {
        numberOfImages: 5,
        callbacks: {
          loaded: function(captcha) {
            $('div#mycaptcha a').on('click', function(event) {
              event.preventDefault();
            });
          }
        }
      }
    });
    var captcha = captchaEl.data('captcha');

    var _sayIsVisualCaptchaFilled = function(event) {
      event.preventDefault();
      if (captcha.getCaptchaData().valid) {
        var chosen_img_data = {
          'value': captcha.getCaptchaData().value
        };
        $.post('/captcha/try', chosen_img_data, function (data, status) {
          if(data.ret == "success") {
            is_ok_captcha = true;
            clean_below_msg(btnSubmit);
            do_signup();
          }
          else {
            is_ok_captcha = false;
            show_below_msg(btnSubmit, "验证码图像选择错误");
          }
        });
      }
      else {
        is_ok_captcha = false;
        show_below_msg(btnSubmit, "请选验证码图像");
      }
    };
    btnSubmit.on('click.app', _sayIsVisualCaptchaFilled);

    // checking fields when blur
    $("input[name='login_name']").blur(function (event) {
      check_name();
    });
    $("input[name='email']").blur(function (event) {
      check_email();
    });
    $("input[name='password']").blur(function (event) {
      check_password();
    });
  });
}(window, jQuery));
