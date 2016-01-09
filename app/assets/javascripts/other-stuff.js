/*
 * Reset session variables for filters
 */
function reset_filters(m, l) {
  jQuery.getJSON('/reset_filters', function(data) {
    window.location = l;
  });
}

/*
 * Capitalizes character on each key press (onkeyup)
 */
function caps(e) {
  var actualValue = e.value;         
  var upperValue = e.value.toUpperCase();
  if (actualValue != upperValue) {
    e.value = upperValue;         
  }   
  //e.value = e.value.toUpperCase();
}

/*
 * Replace spaces & special characters with underscores (special for tag label for)
 */
function replace_with_underscore(l) {
  var r = l.replace(/[^a-z0-9\s]/gi, '_').replace(/ /g,'_');
  return r;
}

/*
 * Checks if it is a numeric digit on each key press (onkeydown)
 */
function only_digit(e) {
  // Allow: backspace, delete, tab, escape, enter, . and ,
  if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190, 188]) !== -1 ||
  // Allow: Ctrl+A
  (e.keyCode == 65 && e.ctrlKey === true) ||
  // Allow: Ctrl+R
  (e.keyCode == 82 && e.ctrlKey === true) ||
  // Allow: home, end, left, right, down, up
  (e.keyCode >= 35 && e.keyCode <= 40)) {
    // let it happen, don't do anything
    return;
  }
  // Ensure that it is a number and stop the keypress
  if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
    e.preventDefault();
  }
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
  var o = (hh<10 ? '0' : '') + hh + ':' + (mm<10 ? '0' : '') + mm + ':' + (ss<10 ? '0' : '') + ss;
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
 * Format date string
 * n parameter must be a string, l parameter must be current localization (I18n.locale)
 * returns YYYYMMDD formatted string
 */
function right_date(n, l) {
  var dd = '', mm = '', yy = '', o = '';
  if (l = 'es') {   // DD/MM/YYYY
    dd = n.substring(0,2);
    mm = n.substring(3,5);
    yy = n.substring(6,10);
  } else {          // MM-DD-YYYY
    mm = n.substring(0,2);
    dd = n.substring(3,5);
    yy = n.substring(6,10);
  }
  o = yy + mm + dd;
  return o;
}

/*
 * AJAX sorting
 * $(document).ready at each index view
 */

/*
 * Scroll & movement
 */
// Modal body (go top & go bottom)
function scrollToAnchorModal(aid) {
  $('.modal-body').animate({scrollTop: $(aid).position().top});
}
//Modal body (go to & focus)
function goToAnchorModal(aid) {
  scrollToAnchorModal(aid);
  $(aid).focus();
}
