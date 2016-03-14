$().ready(function () {

  $("button#btn-search-user").click(function () {
    var name = $("input#search-username").val();
    $.get('/admin/user/' + name, function (data, status) {
      console.log(data);

      
    });
  });
});
