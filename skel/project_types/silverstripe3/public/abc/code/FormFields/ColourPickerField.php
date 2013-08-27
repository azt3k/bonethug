<?php
/**
 * This field lets you put an arbitrary piece of HTML into your forms.
 * 
 * <b>Usage</b>
 * 
 * <code>
 * new LiteralField (
 *    $name = "literalfield",
 *    $content = '<b>some bold text</b> and <a href="http://silverstripe.com">a link</a>'
 * )
 * </code>
 * 
 * @package forms
 * @subpackage fields-dataless
 */
class ColourPickerField extends TextField {
	
	public function __construct($name, $title = null, $value = '', $maxLength = null, $form = null) {
		parent::__construct($name, $title, $value, $maxLength, $form);
		Requirements::javascript(ABC_PATH.'/javascript/library/jQuery/colorpicker/js/colorpicker.js');
		Requirements::customScript(file_get_contents($_SERVER['DOCUMENT_ROOT'].'/'.ABC_PATH.'/javascript/ColourPickerField.js'));
		Requirements::css(ABC_PATH.'/javascript/library/jQuery/colorpicker/css/colorpicker.css');
		$this->addExtraClass('text');
	}
	
}
