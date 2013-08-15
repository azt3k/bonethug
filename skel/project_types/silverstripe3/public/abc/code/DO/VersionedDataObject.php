<?php

/* USE MODIFIED REMODELADMIN */

class VersionedDataObject  extends DataObject implements PermissionProvider{

	public static $db = array(
		'Title'			=> 'Varchar(255)',
		'URLSegment'	=> 'Varchar(255)'
	);

    static $defaults = array(  
		'Title' 		=> 'New Item',
		'URLSegment' 	=> 'new-item'
	);	
	/*
	static $indexes = array(
		"URLSegment" 	=> true,
		"Title"			=> array("type" => "fulltext", "value" => "Title", "name" => "Title")	
	);    
	*/
		
	static $versioning = array(
		"Stage",  "Live"
	);    

	static $extensions = array(
		"Versioned('Stage', 'Live')"
	);
	
	static $many_many = array(
		"ViewerGroups" => "Group",
		"EditorGroups" => "Group"
	);
			
    public function providePermissions(){
		return array(
			'CREATE_VERSIONEDDATAOBJECT' => array(
				'name' => _t(
					'Permission.CREATE_VERSIONEDDATAOBJECT_NAME',
					'Create Versioned DataObjects'
				),
				'category' => _t(
					'Permission.VERSIONEDDATAOBJECT_CATEGORY',
					'Versioned Data Objects'
				),
				'help' => _t(
					'Permission.CREATE_VERSIONEDDATAOBJECT_HELP',
					'Allow the user to create versioned DataObjects'
				),
				'sort' => 100
			),
			'VIEW_VERSIONEDDATAOBJECT' => array(
				'name' => _t(
					'Permission.VIEW_VERSIONEDDATAOBJECT_NAME',
					'View Versioned DataObjects'
				),
				'category' => _t(
					'Permission.VERSIONEDDATAOBJECT_CATEGORY',
					'Versioned Data Objects'
				),
				'help' => _t(
					'Permission.VIEW_VERSIONEDDATAOBJECT_HELP',
					'Allow the user to view versioned DataObjects'
				),
				'sort' => 100
			),			
			'PUBLISH_VERSIONEDDATAOBJECT' => array(
				'name' => _t(
					'Permission.PUBLISH_VERSIONEDDATAOBJECT_NAME',
					'Publish Versioned DataObjects'
				),
				'category' => _t(
					'Permission.VERSIONEDDATAOBJECT_CATEGORY',
					'Versioned Data Objects'
				),
				'help' => _t(
					'Permission.PUBLISH_VERSIONEDDATAOBJECT_HELP',
					'Allow the user to publish versioned DataObjects'
				),
				'sort' => 100
			)			
		);
    }	

	public function Link(){
		die('You must implement Link() in your extended class');
	}

	public function getPublicationStatus(){
		
		if ( $this->isPublished() && ! $this->getIsModifiedOnStage() && !$this->getIsDeletedFromStage() ){
			return 'Published';
		}elseif( $this->getIsModifiedOnStage() && $this->getExistsOnLive() ){
			return 'Changed';
		}elseif( $this->getIsAddedToStage() ){
			return 'Unpublished';
		}elseif( $this->getIsDeletedFromStage() ){
			return 'Deleted from Draft Site';
		}elseif( $this->isNew() ){
			return 'New';
		}else{
			return 'Unable to determine status';
		}
	}

	public function hasStageVersion(){
		
		if ( $this->isPublished() && !$this->getIsDeletedFromStage() ){
			return true;
		} elseif ( $this->getIsModifiedOnStage() && !$this->getIsDeletedFromStage() ){
			return true;
		} elseif ( $this->getIsAddedToStage() ){
			return true;
		} elseif ( $this->getIsDeletedFromStage() ){
			return false;
		}

		return false;	
	}

	public function hasLiveVersion(){
		
		if ( $this->isPublished() ){
			return true;
		} elseif ( $this->getExistsOnLive() ){
			return true;
		} elseif ( $this->getIsAddedToStage() ){
			return false;
		} elseif ( $this->getIsDeletedFromStage() ){
			return false;
		}

		return false;	
	}

	/**
	 * Check if this page is new - that is, if it has yet to have been written
	 * to the database.
	 *
	 * @return boolean True if this page is new.
	 */
	function isNew() {
		/**
		 * This check was a problem for a self-hosted site, and may indicate a
		 * bug in the interpreter on their server, or a bug here
		 * Changing the condition from empty($this->ID) to
		 * !$this->ID && !$this->record['ID'] fixed this.
		 */
		if(empty($this->ID)) return true;

		if(is_numeric($this->ID)) return false;

		return stripos($this->ID, 'new') === 0;
	}


	/**
	 * Check if this page has been published.
	 *
	 * @return boolean True if this page has been published.
	 */
	function isPublished() {
		if($this->isNew())
			return false;

		return (DB::query("SELECT \"ID\" FROM \"".get_class($this)."_Live\" WHERE \"ID\" = $this->ID")->value())
			? true
			: false;
	}

	/**
	 * Compares current draft with live version,
	 * and returns TRUE if no draft version of this page exists,
	 * but the page is still published (after triggering "Delete from draft site" in the CMS).
	 * 
	 * @return boolean
	 */
	function getIsDeletedFromStage() {
		if(!$this->ID) return true;
		if($this->isNew()) return false;
		
		$stageVersion = Versioned::get_versionnumber_by_stage(get_class($this), 'Stage', $this->ID);

		// Return true for both completely deleted pages and for pages just deleted from stage.
		return !($stageVersion);
	}
	
	/**
	 * Return true if this page exists on the live site
	 */
	function getExistsOnLive() {
		return (bool)Versioned::get_versionnumber_by_stage(get_class($this), 'Live', $this->ID);
	}

	/**
	 * Compares current draft with live version,
	 * and returns TRUE if these versions differ,
	 * meaning there have been unpublished changes to the draft site.
	 * 
	 * @return boolean
	 */
	public function getIsModifiedOnStage() {
		// new unsaved pages could be never be published
		if($this->isNew()) return false;
		
		$stageVersion = Versioned::get_versionnumber_by_stage(get_class($this), 'Stage', $this->ID);
		$liveVersion =	Versioned::get_versionnumber_by_stage(get_class($this), 'Live', $this->ID);

		return ($stageVersion && $stageVersion != $liveVersion);
	}
	
	/**
	 * Compares current draft with live version,
	 * and returns true if no live version exists,
	 * meaning the page was never published.
	 * 
	 * @return boolean
	 */
	public function getIsAddedToStage() {
		// new unsaved pages could be never be published
		if($this->isNew()) return false;
		
		$stageVersion = Versioned::get_versionnumber_by_stage(get_class($this), 'Stage', $this->ID);
		$liveVersion =	Versioned::get_versionnumber_by_stage(get_class($this), 'Live', $this->ID);

		return ($stageVersion && !$liveVersion);
	}		

	public function canView($member = null) {
		if(!$member || !(is_a($member, 'Member')) || is_numeric($member)) {
			$member = Member::currentUserID();
		}

		// admin override
		if($member && Permission::checkMember($member, array("ADMIN", "VIEW_VERSIONEDDATAOBJECT"))) return true;

		// Standard mechanism for accepting permission changes from decorators
		$extended = $this->extendedCan('canView', $member);
		if($extended !== null) return $extended;
		
		// check for empty spec
		if(!$this->CanViewType || $this->CanViewType == 'Anyone') return true;

		// check for inherit
		if($this->CanViewType == 'Inherit') {
			if($this->ParentID) return $this->Parent()->canView($member);
			else return $this->getSiteConfig()->canView($member);
		}
		
		// check for any logged-in users
		if($this->CanViewType == 'LoggedInUsers' && $member) {
			return true;
		}
		
		// check for specific groups
		if($member && is_numeric($member)) $member = DataObject::get_by_id('Member', $member);
		if(
			$this->CanViewType == 'OnlyTheseUsers' 
			&& $member 
			&& $member->inGroups($this->ViewerGroups())
		) return true;
		
		return false;
	}

	public function canDelete($member = null) {
		if($member instanceof Member) $memberID = $member->ID;
		else if(is_numeric($member)) $memberID = $member;
		else $memberID = Member::currentUserID();
		
		if($memberID && Permission::checkMember($memberID, array("ADMIN", "CREATE_VERSIONEDDATAOBJECT"))) {
			return true;
		}
		
		// Standard mechanism for accepting permission changes from decorators
		$extended = $this->extendedCan('canDelete', $memberID);
		if($extended !== null) return $extended;
		
		// Check cache (the can_edit_multiple call below will also do this, but this is quicker)
		if(isset(self::$cache_permissions['delete'][$this->ID])) {
			return self::$cache_permissions['delete'][$this->ID];
		}
		
		// Regular canEdit logic is handled by can_edit_multiple
		$results = self::can_delete_multiple(array($this->ID), $memberID);
		
		// If this page no longer exists in stage/live results won't contain the page.
		// Fail-over to false
		return isset($results[$this->ID]) ? $results[$this->ID] : false;
	}

	public function canCreate($member = null) {
		if(!$member || !(is_a($member, 'Member')) || is_numeric($member)) {
			$member = Member::currentUserID();
		}

		if ( $member && Permission::checkMember($member, array("ADMIN", "CREATE_VERSIONEDDATAOBJECT")) ) return true;
		
		// Standard mechanism for accepting permission changes from decorators
		$extended = $this->extendedCan('canCreate', $member);
		if($extended !== null) return $extended;
		
		return $this->stat('can_create') != false || Director::isDev();
	}

	public function canEdit($member = null) {
		if($member instanceof Member) $memberID = $member->ID;
		else if(is_numeric($member)) $memberID = $member;
		else $memberID = Member::currentUserID();
		
		if($memberID && Permission::checkMember($memberID, array("ADMIN", "CREATE_VERSIONEDDATAOBJECT"))) return true;
		
		// Standard mechanism for accepting permission changes from decorators
		$extended = $this->extendedCan('canEdit', $memberID);
		if($extended !== null) return $extended;

		if($this->ID) {
			// Check cache (the can_edit_multiple call below will also do this, but this is quicker)
			if(isset(self::$cache_permissions['CanEditType'][$this->ID])) {
				return self::$cache_permissions['CanEditType'][$this->ID];
			}
		
			// Regular canEdit logic is handled by can_edit_multiple
			$results = self::can_edit_multiple(array($this->ID), $memberID);

			// If this page no longer exists in stage/live results won't contain the page.
			// Fail-over to false
			return isset($results[$this->ID]) ? $results[$this->ID] : false;
			
		// Default for unsaved pages
		} else {
			return $this->getSiteConfig()->canEdit($member);
		}
	}

	public function canPublish($member = null) {
		if(!$member || !(is_a($member, 'Member')) || is_numeric($member)) $member = Member::currentUser();
		
		if($member && Permission::checkMember($member, array("ADMIN", "PUBLISH_VERSIONEDDATAOBJECT"))) return true;

		// Standard mechanism for accepting permission changes from decorators
		$extended = $this->extendedCan('canPublish', $member);
		if($extended !== null) return $extended;

		// Normal case - fail over to canEdit()
		// return $this->canEdit($member);
		return false;
	}
	
	public function canDeleteFromLive($member = null) {
		// Standard mechanism for accepting permission changes from decorators
		$extended = $this->extendedCan('canDeleteFromLive', $member);
		if($extended !==null) return $extended;
		return $this->canPublish($member);
	}

	public function canUnpublish($member = null) {
		return $this->canDeleteFromLive($member);
	}	
	
    //Create duplicate button
	public function getCMSActions()
	{
		$Actions = parent::getCMSActions();

		// Save
		if ($this->canCreate() && !$this->getIsDeletedFromStage()) {
			$SaveAction = FormAction::create('save', 'Save');
			$SaveAction->describe("Save a draft of this item");
			$Actions->insertFirst($SaveAction);
		}
		
		// Restore
		if ($this->canCreate() && $this->getIsDeletedFromStage()) {
			$RestoreAction = FormAction::create('restore', 'Restore');
			$RestoreAction->describe("Restore the draft of this item");
			$Actions->insertFirst($RestoreAction);
		}		

		// Save & Publish
		if ($this->canPublish() && !$this->getIsDeletedFromStage()) {
			$PublishAction = FormAction::create('publish', 'Save & Publish');
			$PublishAction->describe("Publish this item");
			$Actions->insertFirst($PublishAction);
		}

		// Unpublish
		if($this->Status != 'Draft' && $this->canDeleteFromLive() && !$this->getIsDeletedFromStage()) {
			$unPublishAction = FormAction::create('unpublish', 'Unpublish');
			$unPublishAction->describe("Unpublish this item");
			$Actions->insertFirst($unPublishAction);		 	
		}

		// Delete
		if ( $this->canDelete() && ( !$this->isNew() || $this->getIsDeletedFromStage() ) ) {
			$label = $this->hasStageVersion() ? 'Delete from Draft Site' : 'Delete from Live Site' ;
	        $DeleteAction = FormAction::create('delete', $label);
	        $DeleteAction->describe($label);
			$Actions->insertFirst($DeleteAction);
		}
		
		// Return to List
		/*
		$ListViewAction = FormAction::create('listview', 'Go back to list');
	    $ListViewAction->describe("Return to the list");
		$Actions->insertFirst($ListViewAction);
        */
		
		return $Actions;
	}
	
	/**
	 * Publish this page.
	 * 
	 * @uses SiteTreeDecorator->onBeforePublish()
	 * @uses SiteTreeDecorator->onAfterPublish()
	 */
	function doPublish() {
		if (!$this->canPublish()) return false;

		$class = get_class();
		$original = Versioned::get_one_by_stage($class, "Live", $class."_Live.ID = ".$this->ID);
		if(!$original) $original = new $class;

		// Handle activities undertaken by decorators
		$this->invokeWithExtensions('onBeforePublish', $original);
		$this->Status = "Published";
		//$this->PublishedByID = Member::currentUser()->ID;
		$this->write();
		$this->publish("Stage", "Live");

		// Handle activities undertaken by decorators
		$this->invokeWithExtensions('onAfterPublish', $original);
		
		return true;
	}

	/**
	 * Unpublish this DataObject - remove it from the live site
	 * 
	 */
	function doUnpublish() 
	{
		if(!$this->ID) return false;
		if (!$this->canUnPublish()) return false;
		
		$this->extend('onBeforeUnpublish');
		
		$origStage = Versioned::current_stage();
		Versioned::reading_stage('Live');

		// This way our ID won't be unset
		$clone = clone $this;
		$clone->delete();

		Versioned::reading_stage($origStage);

		// If we're on the draft site, then we can update the status.
		// Otherwise, these lines will resurrect an inappropriate record
		if(
			DB::query("SELECT ID FROM ".get_class()." WHERE ID = ".$this->ID)->value()
			&& Versioned::current_stage() != 'Live'
		) {
			$this->Status = "Draft";
			$this->write();
		}

		$this->extend('onAfterUnpublish');

		return true;
	}
	
	/**
	 * Revert the draft changes: replace the draft content with the content on live
	 */
	function doRevertToLive() {
		
		$this->publish("Live", "Stage", false);

		// Use a clone to get the updates made by $this->publish
		$clone = DataObject::get_by_id(get_class($this), $this->ID);
		$clone->Status = "Published";
		$clone->writeWithoutVersion();

		// Need to update pages linking to this one as no longer broken
		foreach($this->DependentPages(false) as $page) {
			// $page->write() calls syncLinkTracking, which does all the hard work for us.
			$page->write();
		}
		
		$this->extend('onAfterRevertToLive');
	}
	
	/**
	 * Restore the content in the active copy of this SiteTree page to the stage site.
	 * @return The SiteTree object.
	 */
	function doRestoreToStage() {
		
		// if no record can be found on draft stage (meaning it has been "deleted from draft" before),
		// create an empty record
		if(!DB::query("SELECT \"ID\" FROM \"".get_class()."\" WHERE \"ID\" = ".$this->ID)->value()) {
			$conn = DB::getConn();
			if(method_exists($conn, 'allowPrimaryKeyEditing')) $conn->allowPrimaryKeyEditing(get_class(), true);
			DB::query("INSERT INTO \"".get_class()."\" (\"ID\") VALUES (".$this->ID.")");
			if(method_exists($conn, 'allowPrimaryKeyEditing')) $conn->allowPrimaryKeyEditing(get_class(), false);
		}
		
		$oldStage = Versioned::current_stage();
		Versioned::reading_stage('Stage');
		$this->forceChange();
		$this->writeWithoutVersion();
		
		$result = DataObject::get_by_id($this->class, $this->ID);
		
		Versioned::reading_stage($oldStage);
		
		return $result;
	}	

	function doDelete() {
		
		$this->doUnpublish();
		
		$oldMode = Versioned::get_reading_mode();
		Versioned::reading_stage('Stage');

		//delete all versioned objects with this ID
		$result = DB::query("DELETE FROM ".get_class($this)."_versions WHERE RecordID = ".$this->ID);
		$result = $this->delete();
				
		Versioned::set_reading_mode($oldMode);

		return $result;
	}

	/**
	 * Check whether this DO has changes which are not published
	 */
	public function hasChangesOnStage()
	{
		$latestPublishedVersion = $this->get_versionnumber_by_stage(get_class(), 'Live', $this->ID);
		$latestVersion = $this->get_versionnumber_by_stage(get_class(), 'Stage', $this->ID);
		return ($latestPublishedVersion < $latestVersion);
	}

	//Test whether the URLSegment exists already on another Product
    function LookForExistingURLSegment($URLSegment,$stage = '')
    {
    	$class = get_class();
    	$stage = $stage ? $stage : Versioned::current_stage();
		$item = DataObject::get_one($class, $class.($stage == 'Live' ? '_'.$stage : '').".URLSegment = '".$URLSegment."'");
		return !$item || $item->ID == $this->ID ? false : true ;
    }

	// Event callbacks
	// ---------------------------------------------------------------------------------------------------------------------------------------

    public function onBeforeWrite()
    {

    	/* URL Segment
    	---------------------------------------*/

		// Set URLSegment to be unique on write    	
        // If there is no URLSegment set, generate one from Title
        $class = get_class($this);
        if(
        	(
	        	(!$this->URLSegment || $this->URLSegment == $class::$defaults['URLSegment']) ||
	        	$this->isChanged('Title')
        	) && (
        		$this->Title != $class::$defaults['Title']
        	)
        ){
            
            $this->URLSegment = SiteTree::generateURLSegment($this->Title);

        }elseif($this->isChanged('URLSegment')){

            // Make sure the URLSegment is valid for use in a URL
            $segment = preg_replace('/[^A-Za-z0-9]+/','-',$this->URLSegment);
            $segment = preg_replace('/-+/','-',$segment);
              
            // If after sanitising there is no URLSegment, give it a reasonable default
            if(!$segment) {
                $segment = $class::$defaults['URLSegment']."-".$this->ID;
            }
            $this->URLSegment = $segment;

        }
  
        // Ensure that this object has a non-conflicting URLSegment value.
        $count = 2;
        while($this->LookForExistingURLSegment($this->URLSegment))
        {
            $this->URLSegment = preg_replace('/-[0-9]+$/', null, $this->URLSegment) . '-' . $count;
            $count++;
        }
  
        parent::onBeforeWrite();
    }

	public function onAfterWrite() {
   		parent::onAfterWrite();
		// Clear out obselete versions of records since there is no way to role back to previous versions yet.
		if(DB::query("SELECT ID FROM ".get_class()." WHERE ID = ".$this->ID)->value()) {
			
			$LiveVersionID = DB::query("SELECT Version FROM ".get_class()."_Live WHERE ID = ".$this->ID)->value();
			$DraftVersionID = DB::query("SELECT Version FROM ".get_class()." WHERE ID = ".$this->ID)->value();
			
			if($LiveVersionID){
				DB::query("DELETE FROM ".get_class()."_versions WHERE RecordID = ".$this->ID." AND Version != '".$DraftVersionID."' AND Version != '".$LiveVersionID."'");
			} else {
				DB::query("DELETE FROM ".get_class()."_versions WHERE RecordID = ".$this->ID." AND Version != '".$DraftVersionID."'");
			}
		}
	}

}