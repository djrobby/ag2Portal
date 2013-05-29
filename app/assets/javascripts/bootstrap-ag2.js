/*
 * App specific Bootstrap functions
 * 
 * For generic placement on ruby html tags:
 * :rel => 'tooltip', "data-placement" => "top/left/bottom/right"
 */
jQuery(function($) {
  // Tooltips
  //  Identified
	$('#undo').tooltip({placement:'right'});
  $('#redo').tooltip({placement:'right'});
  //  Generic
	$('a[rel~="tooltip"]').tooltip();
	
	// Popovers
})
