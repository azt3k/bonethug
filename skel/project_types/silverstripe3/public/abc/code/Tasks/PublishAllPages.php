<?php

class PublishAllPages extends BuildTask {
	
	protected $title		= 'Publish all Pages';
	protected $description 	= 'Publish all Pages';
	protected $enabled 		= true;

	/**
	 * Run the task, and do the business
	 *
	 * @param SS_HTTPRequest $httpRequest 
	 */
	function run($httpRequest) {

		echo 'running publish all pages task...';

		$pages = DataObject::get('Page');
		foreach($pages as $page){
			$page->doPublish();
			echo "published ".$page->Title."<br />";
		}

		$pages = DataObject::get('Album');
		foreach($pages as $page){
			$page->doPublish();
			echo "published ".$page->Title."<br />";
		}		
		echo 'finished';
	}
	
}