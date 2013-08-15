<% if Paginator.TotalHits %>
	<table class="clist-table" cellpadding="0" cellspacing="0" border="0">
		<thead>
			<tr>
				<td>Date Created</td>
				<td>Last Edited</td>
				<td>Publication Date</td>
				<td>Status</td>	
				<td>Title</td>
			</tr>
		</thead>
		<tbody>
			<% control DataSet %>
				<tr class="row-{$Modulus(2)}">
					<td>$Created.Nice</td>
					<td>$LastEdited.Nice</td>
					<td>$PublicationDate.Nice</td>
					<td>$PublicationStatus</td>
					<td>$Title</td>
				</tr>
			<% end_control %>
		</tbody>
	</table>
	<div class="clist-pagination">
		<% include Pagination %>
	</div>
<% end_if %>