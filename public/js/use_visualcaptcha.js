( function( window, $ ) {
  $( function() {
    var captchaEl = $( '#sample-captcha' ).visualCaptcha({
      imgPath: '/images/',
      captcha: {
        numberOfImages: 5,
        callbacks: {
          loaded: function( captcha ) {
            // Avoid adding the hashtag to the URL when clicking/selecting visualCaptcha options
            $( '#sample-captcha a' ).on( 'click', function( event ) {
              event.preventDefault();
            });
          }
        }
      }
    });
    var captcha = captchaEl.data( 'captcha' );

    var _sayIsVisualCaptchaFilled = function( event ) {
      event.preventDefault();
      if ( captcha.getCaptchaData().valid ) {
        var chosen_img_data = {
          'value': captcha.getCaptchaData().value
        };
        $.post('/captcha/try', chosen_img_data, function (data, status) {
          if(data.ret == "success") {
            do_register();
          }
          else if(data.ret == "failed") {
            $("#err-msg2").text("错误的图像");
          }
          else {
            $("#err-msg2").text(data.msg);
          }
        })
      } else {
        $("#err-msg2").text("请选取一个图像");
      }
    };
    $( '#check-is-filled' ).on( 'click.app', _sayIsVisualCaptchaFilled );
  });
}( window, jQuery ) );
