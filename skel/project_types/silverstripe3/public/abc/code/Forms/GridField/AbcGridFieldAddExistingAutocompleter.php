<?php

class AbcGridFieldAddExistingAutocompleter extends GridFieldAddExistingAutocompleter {
	
	/**
	 * Returns a json array of a search results that can be used by for example Jquery.ui.autosuggestion
	 *
	 * @param GridField $gridField
	 * @param SS_HTTPRequest $request 
	 */
	public function doSearch($gridField, $request) {
		$dataClass = $gridField->getList()->dataClass();
		$allList = DataList::create($dataClass);
		$filters = array();
		$stmts = array();
		
		$searchFields = ($this->getSearchFields()) ? $this->getSearchFields() : $this->scaffoldSearchFields($dataClass);
		if(!$searchFields) {
			throw new LogicException(
				sprintf('GridFieldAddExistingAutocompleter: No searchable fields could be found for class "%s"', $dataClass)
			);
		}
		// TODO Replace with DataList->filterAny() once it correctly supports OR connectives
		foreach($searchFields as $searchField) {
			$stmts[] .= 'LOWER('.$searchField.') LIKE \'%'.strtolower(Convert::raw2sql($request->getVar('gridfield_relationsearch'))).'%\'';
		}
		$results = $allList->where(implode(' OR ', $stmts));
		$results = $results->sort($searchFields[0], 'ASC');
		$results = $results->limit($this->getResultsLimit());

		$json = array();
		foreach($results as $result) {
			$json[$result->ID] = SSViewer::fromString($this->resultsFormat)->process($result);
		}
		return Convert::array2json($json);
	}
	
}
