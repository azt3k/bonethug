<?php

require '../../vendor/autoload.php';

use Symfony\Component\Yaml\Yaml;

class SS_LoadConf {

	protected static $constants_set = false;
	// ss env translation
	protected static $ss_env = array(
		'development'	=> 'dev',
		'staging'		=> 'test',
		'production'	=> 'live'
	);

	public static function set_constants() {

		if (!self::$constants_set) {

			// Transfer environmental vars to constants
			if (!defined('APPLICATION_ENV')) 		define('APPLICATION_ENV', getenv('APPLICATION_ENV'));
			if (!defined('PATH')) 					define('PATH', getenv('PATH'));
			if (!defined('SS_SEND_ALL_EMAILS_TO'))	define('SS_SEND_ALL_EMAILS_TO', getenv('SS_SEND_ALL_EMAILS_TO'));

			// Set SS env vars
			if (!getenv('SS_ENVIRONMENT_TYPE')) {		
				putenv('SS_ENVIRONMENT_TYPE='.self::$ss_env[APPLICATION_ENV]);
				define('SS_ENVIRONMENT_TYPE', getenv('SS_ENVIRONMENT_TYPE'));
			}

			self::$constants_set = true;
		}

	}

	public static function translate_env($env) {
		if (!empty(self::$ss_env[$env])) {
			return self::$ss_env[$env];
		} else {
			return $env;
		}
	}
	
	public static function cnf() {

		// ensure constants are set;
		self::set_constants();

		// paths
		$base_dir = realpath(__DIR__ . '/..');
		$public_dir = realpath($base_dir . '/public');

		// load conf
		$cnf = Yaml::parse($base_dir . '/config/cnf.yml');

		// expected urls
		$url = 'http://' . $cnf['apache'][APPLICATION_ENV]['server_name'];		

		// load db settings
		$db = (object) $cnf['dbs']['default'][APPLICATION_ENV];

		// load mail settings
		$mail = (object) $cnf['mail']['smtp'][APPLICATION_ENV];

		return (object) array(
			'cnf'			=> $cnf,
			'db'			=> $db,
			'mail'			=> $mail,
			'base_path'		=> $base_dir,
			'public_path'	=> $public_dir,
			'url'			=> $url
		);

	}

	public static function conf() { return self::cnf(); }
	public static function config() { return self::cnf(); }	

}