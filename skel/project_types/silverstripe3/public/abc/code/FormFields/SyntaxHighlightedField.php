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
class SyntaxHighlightedField extends TextAreaField {
	
	/**
	 * @var string $content
	 */
	protected $content;

	function __construct($name, $title = null, $value = null, $type="html") {

		// Requirements
		Requirements::javascript('abc/javascript/library/jQuery/snippet/jquery.snippet.min.js');
		Requirements::javascript('abc/javascript/SyntaxHighlightedField.js');		
		Requirements::css('abc/javascript/library/jQuery/snippet/jquery.snippet.min.css');
		
		// classes
		$this->addExtraClass('snippet');
		$this->addExtraClass('snippet-'.$type);

		// call parent constructor
		parent::__construct($name, $title = null, $value = null);
	}
}

?>