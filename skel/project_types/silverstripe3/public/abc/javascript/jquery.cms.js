(function($){

	$(document).ready(function(){

		// manage menu contraction expansion
		$('#heading_sitetree').click(function(){

			// cache the original top value
			if (!$("#TreeTools").data('top')) $("#TreeTools").data('top',$("#TreeTools").css('top')) ;

			// set some vars
			var $this = $(this);
			var h = $("#TreeTools").height();

			// define the target styles
			if ($('#sitetree_holder #TreeTools').css('position') == 'absolute'){
				var position = 'relative';
				var padding = 0;
				var display = 'none';
			}else{
				var position = 'absolute';
				var padding = h;
				var display = 'block';
			}

			// apply the CSS		
			$('#sitetree_holder #TreeTools').css({
				'position'	: position
			});
			$('#sitetree_holder').css({
				'padding-top': padding
			});
			$('#publication_key').css({
				'display'	: display
			});

		});	

		// manage create dialog
		$('li#addpage button').click(function(){
			setTimeout(function(){

				var $this = $(this);
				var h 		= $("#TreeTools").height();
				var sH 		= $('#sitetree_holder').height();
				var sP 		= parseFloat($('#sitetree_holder').css('padding-top'));
				var sTH 	= sH + sP;
				var eH		= sTH - h;

				$('#sitetree_holder').css({
					'padding-top'	: h,
					'height'		: eH
				});

			},200);

		});


	});

})(jQuery);
