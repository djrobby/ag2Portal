function remove_fields(link) {
    $(link).prev("input[type=hidden]").val("1");
    $(link).closest(".fields").hide();
}
 
function add_fields(link, association, content, _window) {
    var new_id = new Date().getTime();
    var regex = new RegExp("new_" + association, "g");
    $(link).parent().after(content.replace(regex, new_id));
    //$('#new-pilot-fields').modal('show');
    $(_window).modal('show');
}