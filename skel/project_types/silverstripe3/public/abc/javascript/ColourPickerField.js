(function($){
	$(document).ready(function(){

		$('.colourpicker:not(.colourpicker-attached)').live('focus',function(){
			
			var $this = $(this);
			
			$this.ColorPicker({
				onChange: function(hsb, hex, rgb){
					$this.val('#'+hex);
				},
				onSubmit: function(hsb, hex, rgb, el) {
					$(el).val(hex);
					$(el).ColorPickerHide();
				},
				onBeforeShow: function() {
					$(this).ColorPickerSetColor(this.value);
				}
			}).bind('keyup', function(){
				$(this).ColorPickerSetColor(this.value);
			}).addClass('colourpicker-attached');
			
		});
		
	});
})(jQuery);