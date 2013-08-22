<?php

require '../../vendor/autoload.php';

use Symfony\Component\Yaml\Yaml;

// ss env translation
$ss_env = array(
	'development'	=> 'dev',
	'staging'		=> 'test',
	'production'	=> 'live'
);

// Transfer environmental vars to constants
define('APPLICATION_ENV', getenv('APPLICATION_ENV'));

// Set SS env vars
putenv('SS_ENVIRONMENT_TYPE='+$ss_env[APPLICATION_ENV]);
define('SS_ENVIRONMENT_TYPE', $ss_env[APPLICATION_ENV]);
define('SS_SEND_ALL_EMAILS_TO', getenv('SS_SEND_ALL_EMAILS_TO'));

global $project, $databaseConfig, $_FILE_TO_URL_MAPPING;

// Project Specific Settings
$project = 'project';
SSViewer::set_theme('project');

// load conf
$cnf = Yaml::parse(__DIR__.'/../../config/cnf.yml');

// load db settings
$db_cnf = (object) $cnf['dbs']['default'][APPLICATION_ENV];

// load mail settings
$mail = (object) $cnf['mail']['smtp'][APPLICATION_ENV];

// file to url
$base_dir = __DIR__ . '/..';
$url = 'http://'.$cnf['apache'][APPLICATION_ENV]['server_name'];
$_FILE_TO_URL_MAPPING[$base_dir] = $url;

// Env specific settings
switch(APPLICATION_ENV){

	case 'development':

		// Debug Settings
		ini_set("display_errors",1);
		error_reporting(E_ALL & ~E_STRICT);		
		Director::set_environment_type("dev");
		
		// Ensure that all emails get directed to the developer email address
		Config::inst()->update('Email', 'send_all_emails_to', SS_SEND_ALL_EMAILS_TO);
		
		// Set admin email
		Config::inst()->update('Email', 'admin_email', SS_SEND_ALL_EMAILS_TO);
		
		// Log file
		SS_Log::add_writer(new SS_LogFileWriter(BASE_PATH.'/../log/development.log'), SS_Log::WARN, '<=');

		// hard code user / pass
		Security::setDefaultAdmin('admin', 'admin');
		
		break;

	case 'staging':	

		// Debug Settings
		ini_set("display_errors",1);
		error_reporting(E_ALL & ~E_STRICT);		
		Director::set_environment_type("test");
		
		// Ensure that all emails get directed to the developer email address
		Email::send_all_emails_to(SS_SEND_ALL_EMAILS_TO);
		
		// Set admin email
		Email::setAdminEmail(SS_SEND_ALL_EMAILS_TO);

		// hard code user / pass
		Security::setDefaultAdmin('admin', 'admin');			
		
		// Log file
		SS_Log::add_writer(new SS_LogFileWriter(BASE_PATH.'/../log/staging.log'), SS_Log::WARN, '<=');
		
		break;

	default:
	case 'production':

		Director::set_environment_type("live");

		// Log file
		SS_Log::add_writer(new SS_LogFileWriter(BASE_PATH.'/../log/production.log'), SS_Log::WARN, '<=');

		break;
		
}

// set up db
$databaseConfig = array(
	"type" 		=> 'MySQLDatabase',
	"server" 	=> $db_cnf->host,
	"username" 	=> $db_cnf->user,
	"password" 	=> $db_cnf->pass,
	"database" 	=> $db_cnf->name,
	"path" 		=> '',
);	
Config::inst()->update('MySQLDatabase', 'connection_charset', 'utf8');

// set up mail
define('SMTPMAILER_DEFAULT_FROM_NAME', 		$mail->default_from['name']);
define('SMTPMAILER_DEFAULT_FROM_EMAIL', 	$mail->default_from['email']);		
define('SMTPMAILER_SMTP_SERVER_ADDRESS',	$mail->server);
define('SMTPMAILER_DO_AUTHENTICATE', 		$mail->authenticate);
define('SMTPMAILER_USERNAME', 				$mail->user);
define('SMTPMAILER_PASSWORD', 				$mail->pass);
define('SMTPMAILER_CHARSET_ENCODING', 		$mail->charset_encoding);
define('SMTPMAILER_USE_SECURE_CONNECTION', 	$mail->secure);
define('SMTPMAILER_SMTP_SERVER_PORT', 		$mail->port);

// Set the site locale
i18n::set_locale('en_NZ');
ini_set("date.timezone","Pacific/Auckland");

// define some Constants
if (!defined('THEME_PATH'))				define('THEME_PATH', 'themes/'.Config::inst()->get('SSViewer','current_theme'));
if (!defined('PROJECT_PATH'))			define('PROJECT_PATH', $project);
if (!defined('UPLOADS_PATH'))			define('UPLOADS_PATH', 'assets/Uploads');
if (!defined('DOCUMENT_ROOT_PATH'))		define('DOCUMENT_ROOT_PATH', $_SERVER['DOCUMENT_ROOT']);
if (!defined('SS_SITE_DATABASE_NAME'))	define('SS_SITE_DATABASE_NAME', $databaseConfig['database']);

//jpeg quality
Config::inst()->update('GDBackend', 'default_quality', 80);