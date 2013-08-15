(function($){
	$(document).ready(function() {

		$("select#Hits").change(function(){
			var value = $(this).val();
			window.location.href = value;
		});

	});
})(jQuery);
