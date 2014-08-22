/*
 * Capitalizes character on each key press (onkeyup)
 */
function caps(e) {
  e.value = e.value.toUpperCase();
}

/*
 * Returns ES formatted date & time
 */
function es_date(d) {
  var month = d.getMonth()+1;
  var day = d.getDate();
  var o = (day<10 ? '0' : '') + day + '/' + (month<10 ? '0' : '') + month + '/' + d.getFullYear();
  return o;
}
function es_time(d) {
  var hh = d.getHours();
  var mm = d.getMinutes();
  var ss = d.getSeconds();
  var o = (hh<10 ? '0' : '') + hh + ':' + (mm<10 ? '0' : '') + mm + ':' + ':' + (ss<10 ? '0' : '') + ss;
  return o;
}

/*
 * Format numeric string with specific decimal digits
 * n parameter must be a number
 * returns en-US formatted number
 */
function right_number(n, l) {
  var r = n.replace(",", ".");
  var p = r.indexOf('.');
  var d = '';
  if (p >= 0) {
    d = r.substring(p + 1);
    if (d.length > l) {
      d = r.length - (d.length - l);
      r = r.substring(0, d);
    }
  }
  return r;
}

/*
 * AJAX sorting
 * $(document).ready at each index view
 */
