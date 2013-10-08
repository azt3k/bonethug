<?php
class Page extends SiteTree {

	protected static $page_cache = array();

	private static $can_be_root = true;	

	private static $db = array(
	);

	private static $has_one = array(
		'PrimaryImage'	=> 'Image'
	);

	public function getCMSFields() {
		
		$fields = parent::getCMSFields();

		$imageField = new UploadField('PrimaryImage', 'Image');
		$imageField->getValidator()->setAllowedExtensions(array('jpg','jpeg','gif','png'));				
		$fields->addFieldToTab('Root.Main', $imageField, 'Content');

		return $fields;
	}

	// Helper functions
	// -----------------

	public static function get_a($pageType = 'Page') {
		$page = null;
		if (!empty(self::$page_cache[$pageType])) $page = self::$page_cache[$pageType];
		else if ($page = DataObject::get_one($pageType)) self::$page_cache[$pageType] = $page;
		return $page;
	}
	
	public function IsA ($className) {
		return is_a($this, $className);
	}
	
	public function AreSamePage ($page1, $page2) {
		return $page1->ID == $page2->ID;
	}	

	public function PaginatedChildren($limit = null, $order = 'Created DESC', $hitsOptions = null){
		
		if ($limit === null) $limit = self::$hits_per_page;
		
		$do					= new DataObject;
		$do->DataSet 		= AbcPaginator::get($limit)->fetch('Page', "ParentID = ".$this->ID, $order);
		$do->Paginator 		= $do->DataSet->Paginator->dataForTemplate($do->DataSet->unlimitedRowCount, 2, null, $hitsOptions);
		$do->HitsSelector	= $do->Paginator->HitsSelector;
		return $do;	
	}	

}
class Page_Controller extends ContentController {

	/**
	 * An array of actions that can be accessed via a request. Each array element should be an action name, and the
	 * permissions or conditions required to allow the user to access it.
	 *
	 * <code>
	 * array (
	 *     'action', // anyone can access this action
	 *     'action' => true, // same as above
	 *     'action' => 'ADMIN', // you must have ADMIN permissions to access this action
	 *     'action' => '->checkAction' // you can only access this action if $this->checkAction() returns true
	 * );
	 * </code>
	 *
	 * @var array
	 */
	private static $allowed_actions = array (
	);

	public function init() {
		parent::init();
	}

}
