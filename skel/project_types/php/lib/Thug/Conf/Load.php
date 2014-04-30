<?php

namespace Thug\Conf;

use Symfony\Component\Yaml\Yaml;

require realpath(__DIR__ . '/../../../vendor/autoload.php');

class Load {

	protected static $constants_set = false;
	protected static $application_env = null;
	protected static $ss_environment_type = null;

	public static function get_application_env() {
		self::set_constants();
		return self::$application_env;
	}

	public static function env() {
		return self::get_application_env();
	}

	public static function get_ss_environment_type() {
		// ensure constants are set;
		self::set_constants();
		return self::$ss_environment_type;
	}

	public static function translate_env($env) {
		if (!empty(self::$ss_env[$env])) {
			return self::$ss_env[$env];
		} else {
			return $env;
		}
	}

	public static function set_constants() {

		if (!self::$constants_set) {

			// Transfer environmental vars to constants
			$env = getenv('APPLICATION_ENV');
			if (!$env) $env = 'production';

			if (!defined('APPLICATION_ENV')) 		define('APPLICATION_ENV', $env);
			if (!defined('PATH')) 					define('PATH', getenv('PATH'));

			self::$constants_set = true;
			self::$application_env = APPLICATION_ENV;

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