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
class ChildListField extends LiteralField {
	
	/**
	 * @var string $content
	 */
	protected $content;

	function __construct($controller, $name, $class = 'Page', $limit = 30) {

		Requirements::javascript('abc/javascript/child-list.js');
		Requirements::css('abc/css/child-list.css');

		$do 			= new DataObject;
		$do->DataSet 	= AddPaginator::get($limit)->fetch($class, "SiteTree.ParentID = ".$controller->ID, "PublicationDate DESC, Created DESC");
		$do->Paginator 	= $do->DataSet->Paginator->dataForTemplate(null,null,'/admin/getitem?ID='.$controller->ID);
		$parser			= SSViewer::fromString(SSViewer::getTemplateContent( 'ChildList' ));
		$str 			= $parser->process($do);

		parent::__construct($name, $str);		

	}
}

?>