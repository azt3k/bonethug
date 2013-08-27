<% if Paginator.PaginatorRequired %>
	<div class="pagination">
		
		Page $Paginator.CurrentPageNum of $Paginator.TotalPages (Total Items: $Paginator.TotalHits)

		|
		
		<% with Paginator.PageLinks %>

			<% if PreviousPage %><a href="$PreviousPage" title="Previous" class="terminator">Prev</a><% end_if %> 
			<% if FirstPage %>
				<a href="$FirstPage" title="First Page" class="terminator <% if Paginator.IsFirst %> selected <% end_if %> ">1</a>
				...
			<% end_if %>

			<% loop QuickLinks %>
				<% if PageLink %>
					<a href="$PageLink">$PageNum</a>
				<% else %>
					<span class="selected">$PageNum</span>
				<% end_if %>
			<% end_loop %>

			<% if LastPage %>
				...
				<a href="$LastPage" title="Last Page" class="terminator <% if Paginator.IsLast %> selected <% end_if %> ">$Total</a>
			<% end_if %>
			<% if NextPage %><a href="$NextPage" title="Next" class="terminator">Next</a><% end_if %>
	
		<% end_with %>
	</div>
<% end_if %>