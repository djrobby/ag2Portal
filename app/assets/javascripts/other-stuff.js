/*
 * Capitalizes character on each key press (onkeyup)
 */
function caps(e) {
  e.value = e.value.toUpperCase();
}

/*
 * Returns ES formatted date
 */
function es_date(d) {
  var month = d.getMonth()+1;
  var day = d.getDate();
  var o = (day<10 ? '0' : '') + day + '/' + (month<10 ? '0' : '') + month + '/' + d.getFullYear();
  return o;
}