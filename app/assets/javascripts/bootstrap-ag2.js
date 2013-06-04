/*
 * App specific Bootstrap functions
 * 
 * For generic placement on ruby html tags:
 * :rel => 'tooltip', "data-placement" => "top/left/bottom/right"
 */
jQuery(function($) {
	// Tooltips
	// Identified
	$('#undo').tooltip({
		placement : 'right'
	});
	$('#redo').tooltip({
		placement : 'right'
	});
	$('#first').tooltip({
		placement : 'bottom',
		delay : {
			show : 500,
			hide : 0
		}
	});
	$('#last').tooltip({
		placement : 'bottom',
		delay : {
			show : 500,
			hide : 0
		}
	});
	$('#next').tooltip({
		placement : 'bottom',
		delay : {
			show : 500,
			hide : 0
		}
	});
	$('#prev').tooltip({
		placement : 'bottom',
		delay : {
			show : 500,
			hide : 0
		}
	});
	// Generic
	$('a[rel~="tooltip"]').tooltip();

	// Popovers
})
