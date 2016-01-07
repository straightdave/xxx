/* only used in /ask page */
$().ready(function () {
  $("input[name='title']").focus();

  $("div.bootstrap-tagsinput input").click(function () {
    console.log("new tag input clicked!");
    $("div[name='tagslist']").show();

  });







});
