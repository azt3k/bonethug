(function($){
	$('.clist-pagination a').live('click',function(e){
		e.preventDefault();
		$this = $(this);
		var href = $this.attr('href')+'&ajax=1';
		$.post(href, '', function (data, textStatus) {
			if(textStatus == 'success' && data){
				var $data = $(data);
				$('#Root_Content_set_Articles').html($data.find('#Root_Content_set_Articles').html());
			}
		});
	});
})(jQuery)