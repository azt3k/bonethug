(function($){
	$(document).ready(function(){
	
		$('.snippet').each(function(){
			var $this = $(this);
			var classes = $this.attr('class').split(' ');
			$.each(classes, function(k,v){
				var pieces = v.split('-');
				if (pieces[0] == 'snippet' && typeof pieces[1] != 'undefined') {
					var type = pieces[1];
					$this.on('keyup', function(e) {
						$el = $(this);
						$el.snippet(type);
					})
				}
			});
		});

	});
})(jQuery);