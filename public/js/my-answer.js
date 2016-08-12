(function (window, $) {
  // this part should just embed in answering part on answer page
  $(function() {
    var _submitBtn = $("button[name='btn_submit']");
    var qid = _submitBtn.attr("data-qid");
    _submitBtn.attr("disabled", "disabled");
    var editor = new wangEditor('answer-editor-box');
    editor.config.menus = [
      'bold','underline','italic','strikethrough','eraser','forecolor','|',
      'quote','fontfamily','fontsize','unorderlist','orderlist','|',
      'link','unlink','table','emotion','img','|',
      'undo','redo','fullscreen'
    ];
    editor.config.uploadImgUrl = '/uploadeditor';
    editor.config.uploadImgFileName = 'uploadedimage';
    editor.config.hideLinkImg = true;
    editor.onchange = function () {
      var text_len = this.$txt.text().length;
      if (text_len > 0) { _submitBtn.removeAttr("disabled"); }
      else { _submitBtn.attr("disabled", "disabled"); }
    }
    editor.create();
    _submitBtn.click(function () {
      console.log("prepare to submit answer to question (id: " + qid + ")");
      if (editor.$txt.text().length > 0) {
        var data = { "content" : editor.$txt.html() };
        $.post("/q/" + qid + "/answer", data, function (data, status) {
          if(data.ret == "success") { location.replace("/q/" + qid);}
          else { alert(data.msg); }
        });
      }
    });
  });
})(window, jQuery);
