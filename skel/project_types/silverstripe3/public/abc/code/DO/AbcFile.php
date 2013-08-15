<?php

class AbcFile extends File {
	
	private static $allowed_extensions = array(
		'','ace','arc','arj','asf','au','avi','bmp','bz2','cab','cda','css','csv','dmg','doc','docx',
		'flv','f4v','gif','gpx','gz','hqx','htm','html','ico','jar','jpeg','jpg','js','kml', 'm4a','m4v',
		'mid','midi','mkv','mov','mp3','mp4','mpa','mpeg','mpg','ogg','ogv','pages','pcx','pdf','pkg',
		'png','pps','ppt','pptx','ra','ram','rm','rtf','sit','sitx','swf','tar','tgz','tif','tiff',
		'txt','wav','webm','webmv','wma','wmv','xhtml','xls','xlsx','xml','zip','zipx',
	);
	
	public static $has_many = array(
		"Attachments"	=> "PageFileAttachment"
	);

	public function getAddFileMimeType(){
		$return = explode('-',self::getFileType());

		return $return[0];
	}

	public function getAddFileFileSize(){
		return self::getSize();
	}
}