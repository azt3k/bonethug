<?php
class HomePage extends RootPage {

	private static $can_be_root = true;	

	private static $db = array(
	);

}

class HomePage_Controller extends RootPage_Controller {

	private static $allowed_actions = array (
	);

	public function init() {
		parent::init();
	}

}
