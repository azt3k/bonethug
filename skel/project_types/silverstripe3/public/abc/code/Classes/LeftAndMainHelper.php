<?php

class LeftAndMainHelper {
	
	protected static $extra_requirements = array(
		'block'		=>	array(),
		'unblock'	=>	array()
	);
	
	public static function require_block($file) {
		self::$extra_requirements['block'][] = array($file);
	}
	
	public static function require_unblock($file) {
		self::$extra_requirements['unblock'][] = array($file);
	}
	
	public static function get_requirements(){
		return self::$extra_requirements;
	}
}