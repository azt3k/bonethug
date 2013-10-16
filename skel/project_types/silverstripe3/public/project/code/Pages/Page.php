<?php
class Page extends SiteTree {

	protected static $page_cache = array();

	private static $can_be_root = false;	

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

	/**
	 * Add default records to database.
	 *
	 * This function is called whenever the database is built, after the
	 * database tables have all been created. Overload this to add default
	 * records when the database is built, but make sure you call
	 * parent::requireDefaultRecords().
	 */
	public function requireDefaultRecords() {
		
		
		if(!SiteTree::get_by_link(Config::inst()->get('RootURLController', 'default_homepage_link'))) {
			$homepage = new HomePage;
			$homepage->Title = 'Home';
			$homepage->URLSegment = Config::inst()->get('RootURLController', 'default_homepage_link');
			$homepage->Sort = 1;
			$homepage->write();
			$homepage->publish('Stage', 'Live');
			$homepage->flushCache();
			DB::alteration_message('Home page created', 'created');
		}

		if(DB::query("SELECT COUNT(*) FROM \"SiteTree\"")->value() == 1) {
			$aboutus = new RootPage;
			$aboutus->Title = 'About Us';
			$aboutus->Sort = 2;
			$aboutus->write();
			$aboutus->publish('Stage', 'Live');
			$aboutus->flushCache();
			DB::alteration_message('Book 1 created', 'created');

			$contactus = new RootPage;
			$contactus->Title = 'Contact Us';
			$contactus->Sort = 3;
			$contactus->write();
			$contactus->publish('Stage', 'Live');
			$contactus->flushCache();
			DB::alteration_message('Book 2 created', 'created');
		}
		
		// call it on the parent
		parent::requireDefaultRecords();		
	}	


}
class Page_Controller extends ContentController {

	private static $allowed_actions = array (
	);

	public function init() {
		parent::init();
	}

}
