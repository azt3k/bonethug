<?php

class AbcImage extends Image {

	public static $fallback_image = null;

	public static $db = array(
		'CapturedBy'	=> 'Varchar(255)',
		'Location'		=> 'Varchar(255)',		
		'DateCaptured'	=> 'Date'
	);
	
	public static $summary_fields = array(
		'Title'			=> 'Title',
		'Filename'		=> 'Filename',
		'CMSThumbnail'	=> 'Preview'
	);

    public function getCMSFields() {  	
	
        $fields = parent::getCMSFields();
        
        // Set some fields
        $fields->addFieldToTab( 'Root.Main', new TextField( 'Location' ) );
		$fields->addFieldToTab( 'Root.Main', new TextField( 'CapturedBy' ) ); 

		// Configure the date field
		$df = new DateField( 'DateCaptured', 'Date Captured (dd/mm/yyyy)' );
		$df->setLocale('en_NZ');
		$df->setConfig('dateformat', 'dd/MM/YYYY');
		$df->setConfig('showcalendar','true'); 
		$fields->addFieldToTab( 'Root.Main', $df );
		//die(print_r($fields));

		// work around for model admin
		//try{ $this->updateCMSFields($fields); }catch(Exception $e){ /* do nothing */ }		

        return $fields;
    }

	public function getCMSFields_forPopup() {
		$fields = $this->getCMSFields();
		$fields->removeByName('current-image');
		$fields->push( new LiteralField( 'Padding' , '<br /><br />') );
		return $fields;
	}	

	public function isValid(){
		return !$this->Filename || !is_file($_SERVER['DOCUMENT_ROOT'].'/'.$this->Filename) ? false : true ;
	}

	protected function failSafe(){
		if (!$this->isValid()){
			if ( !$image = DataObject::get_one('AbcImage',"Filename='".self::$fallback_image."'") ){
				$this->Filename = self::$fallback_image;
				$this->write();
			}else{
				$this->ID = $image->ID;
				$this->Filename = self::$fallback_image;
			}
		}
	}	

	public function resizedAbsoluteURL($w, $h){
		$this->failSafe();
		return !$this->isValid() ? false : Director::absoluteBaseURL().str_replace('%2F','/',rawurlencode($this->setSize($w, $h)->getFilename()));
	}
	
	public function resizedCroppedAbsoluteURL($w, $h){
		$this->failSafe();
		return !$this->isValid() ? false : Director::absoluteBaseURL().str_replace('%2F','/',rawurlencode($this->CroppedImage($w, $h)->getFilename()));
	}

	public function setWidthAbsoluteURL($w){
		$this->failSafe();
		return !$this->isValid() ? false : Director::absoluteBaseURL().str_replace('%2F','/',rawurlencode($this->setWidth($w)->getFilename()));
	}
	
	public function setSizeAbsoluteURL($w, $h) {
		$this->failSafe();
		return !$this->isValid() ? false : Director::absoluteBaseURL().str_replace('%2F','/',rawurlencode($this->SetSize($w,$h)->getFilename()));
	}

}