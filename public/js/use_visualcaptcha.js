(function(window, $) {
  $(function() {
    var captchaEl = $('div#mycaptcha').visualCaptcha({
      imgPath: '/images/',
      captcha: {
        numberOfImages: 5,
        callbacks: {
          loaded: function(captcha) {
            // Avoid adding the hashtag to the URL when clicking/selecting visualCaptcha options
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
            do_signup();
          }
          else {
            $("#signup-err-msg").text("验证码图像选择错误");
          }
        });
      }
      else {
        $("#signup-err-msg").text("请选取一个图像");
      }
    };
    $('#check-is-filled').on('click.app', _sayIsVisualCaptchaFilled);
  });
}(window, jQuery));
