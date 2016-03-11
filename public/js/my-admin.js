$().ready(function () {
  $("a.show-detail").click(function () {
    var id = $(this).attr("name");

    var pane = $("div.account-detail-pane");
    pane.empty();

    $.get('/admin/account/' + id, function (data, status) {
      pane.append(
        "<p> ID: " + id + "</p> \
        <p> name: " + data.login_name + "</p> \
        <div class='btn-group' role='group'> \
        <button class='btn btn-default btn-sm'>挂起</button> \
        <button class='btn btn-default btn-sm'>禁用</button> \
        <button class='btn btn-default btn-sm'>还原</button> \
        </div> \
        ");
    });

  });
});
