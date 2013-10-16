<?php
class RootPage extends Page {

	private static $can_be_root = true;	

	private static $db = array(
	);

}

class RootPage_Controller extends Page_Controller {

	private static $allowed_actions = array (
	);

	public function init() {
		parent::init();
	}

}
