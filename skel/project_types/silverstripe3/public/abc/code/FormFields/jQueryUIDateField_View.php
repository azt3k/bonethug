<?php
/*
	Allows you to set all jQuery UI options and events.
	Usage:
	$DateField = new DateField('myDate');
	$DateField->jQueryConfig = array(
	'changeMonth' => true,
	'changeYear' => true
	);
	$DateField->jQueryEvents = array(
		'beforeShowDay' => "function(date) { 
			// do something with date
		}"
	);
*/
// mysite/code/jQueryUIDateField_View.php
class jQueryUIDateField_View extends DateField_View_JQuery {
	function onBeforeRender() {
		$Field = $this->getField();
		$format = self::convert_iso_to_jquery_format($Field->getConfig('dateformat'));
		$conf = array(
			'dateFormat' => $format
		);

		if($Field->getConfig('showcalendar')) 
			$conf['showcalendar'] = true;
		if ($Field->getConfig('min')) 
			$conf['minDate'] = self::convert_iso_to_jquery_format($Field->getConfig('min'));
		if ($Field->getConfig('max')) 
			$conf['maxDate'] = self::convert_iso_to_jquery_format($Field->getConfig('max'));

		if (!empty($Field->jQueryConfig) && is_array($Field->jQueryConfig)) 
			foreach ($Field->jQueryConfig as $key=>$val)
			$conf[$key] = $val;

		if (!empty($Field->jQueryEvents) && is_array($Field->jQueryEvents)) {	
			$value_arr = array();
			$replace_keys = array();
			foreach($Field->jQueryEvents as $key => $value){
			    // Store function string.
			    $value_arr[] = $value;
			    // Replace function string in $foo with a 'unique' special key.
			    $value = '%' . $key . '%';
			    $conf[$key] = $value;
			    // Later on, we'll look for the value, and replace it.
			    $replace_keys[] = '"' . $value . '"';
			}
		}

		$conf = Convert::raw2json($conf);

		if (!empty($Field->jQueryEvents) && is_array($Field->jQueryEvents)) {
			// Replace the special keys with the original function.
			$conf = str_replace($replace_keys, $value_arr, $conf);
		}

		$conf = str_replace('"', '\'', $conf);

		$this->getField()->addExtraClass($conf);
	}
}