<?php

require '../../vendor/autoload.php';

use Symfony\Component\Yaml\Yaml;

// Transfer environmental vars to constants
define('SS_ENVIRONMENT_TYPE', getenv('SS_ENVIRONMENT_TYPE'));
define('SS_SEND_ALL_EMAILS_TO', getenv('SS_SEND_ALL_EMAILS_TO'));

global $project, $databaseConfig, $_FILE_TO_URL_MAPPING;

// Project Specific Settings
$project = 'project';
SSViewer::set_theme('project');

// load db settings
$cnf = Yaml::parse(__DIR__.'/../../config/cnf.yml');
$db = $cnf['dbs']['default'];

// Env specific settings
switch(SS_ENVIRONMENT_TYPE){

	case 'dev':

		// Debug Settings
		ini_set("display_errors",1);
		error_reporting(E_ALL & ~E_STRICT);		
		Director::set_environment_type("dev");

		// load env db conf
		$db_cnf = (object) $db['development'];	
		
		// Ensure that all emails get directed to the developer email address
		Config::inst()->update('Email', 'send_all_emails_to', SS_SEND_ALL_EMAILS_TO);
		
		// Set admin email
		Config::inst()->update('Email', 'admin_email', SS_SEND_ALL_EMAILS_TO);
		
		// Log file
		SS_Log::add_writer(new SS_LogFileWriter(BASE_PATH.'/../logs/log.log'), SS_Log::WARN, '<=');

		// hard code user / pass
		Security::setDefaultAdmin('admin', 'admin');		
		
		// Smtp Email Conf
		define('SMTPMAILER_DEFAULT_FROM_NAME', 'dev');
		define('SMTPMAILER_DEFAULT_FROM_EMAIL', 'abcdigital@abcdigital.co.nz');		
		define('SMTPMAILER_SMTP_SERVER_ADDRESS', 'smtp.gmail.com'); # SMTP server address
		define('SMTPMAILER_DO_AUTHENTICATE', true); # Turn on SMTP server authentication. Set to false for an anonymous connection
		define('SMTPMAILER_USERNAME', 'abcd.testuser@gmail.com'); # SMTP server username, if SMTPAUTH == true
		define('SMTPMAILER_PASSWORD', 'testing420'); # SMTP server password, if SMTPAUTH == true
		define('SMTPMAILER_CHARSET_ENCODING', 'utf-8'); # E-mails characters encoding, e.g. : 'utf-8' or 'iso-8859-1'
		define('SMTPMAILER_USE_SECURE_CONNECTION', 'tls'); # SMTP encryption method : Set to '' or 'tls' or 'ssl'
		define('SMTPMAILER_SMTP_SERVER_PORT', 587); # SMTP server port. Set to 25 if no encryption or tls. Set to 465 if ssl
		
		break;

	case 'test':	
		// Debug Settings
		ini_set("display_errors",1);
		error_reporting(E_ALL & ~E_STRICT);		
		Director::set_environment_type("test");
		
		// load env db conf
		$db_cnf = (object) $db['staging'];
		
		// Ensure that all emails get directed to the developer email address
		Email::send_all_emails_to(SS_SEND_ALL_EMAILS_TO);
		
		// Set admin email
		Email::setAdminEmail(SS_SEND_ALL_EMAILS_TO);

		// hard code user / pass
		Security::setDefaultAdmin('admin', 'admin');			
		
		// Log file
		SS_Log::add_writer(new SS_LogFileWriter(BASE_PATH.'/../logs/log.log'), SS_Log::WARN, '<=');

		// Smtp Email Conf
		define('SMTPMAILER_DEFAULT_FROM_NAME', 'test');
		define('SMTPMAILER_DEFAULT_FROM_EMAIL', 'abcdigital@abcdigital.co.nz');		
		define('SMTPMAILER_SMTP_SERVER_ADDRESS', 'smtp.gmail.com'); # SMTP server address
		define('SMTPMAILER_DO_AUTHENTICATE', true); # Turn on SMTP server authentication. Set to false for an anonymous connection
		define('SMTPMAILER_USERNAME', 'abcd.testuser@gmail.com'); # SMTP server username, if SMTPAUTH == true
		define('SMTPMAILER_PASSWORD', 'testing420'); # SMTP server password, if SMTPAUTH == true
		define('SMTPMAILER_CHARSET_ENCODING', 'utf-8'); # E-mails characters encoding, e.g. : 'utf-8' or 'iso-8859-1'
		define('SMTPMAILER_USE_SECURE_CONNECTION', 'tls'); # SMTP encryption method : Set to '' or 'tls' or 'ssl'
		define('SMTPMAILER_SMTP_SERVER_PORT', 587); # SMTP server port. Set to 25 if no encryption or tls. Set to 465 if ssl
		
		// Requirements::javascript('http://www.bugherd.com/sidebarv2.js?apikey=lmnw4b6srak6dujqwjqchw');
		
		break;

	default:
	case 'live':

		Director::set_environment_type("live");		
		
		// load env db conf
		$db_cnf = (object) $db['production'];

		// Log file
		SS_Log::add_writer(new SS_LogFileWriter(BASE_PATH.'/../logs/log.log'), SS_Log::WARN, '<=');
		
		// hard code user / pass
		Security::setDefaultAdmin('admin', 'admin');		
		
		// Smtp Email Conf
		define('SMTPMAILER_DEFAULT_FROM_NAME', 'live');
		define('SMTPMAILER_DEFAULT_FROM_EMAIL', 'abcdigital@abcdigital.co.nz');		
		define('SMTPMAILER_SMTP_SERVER_ADDRESS', 'smtp.gmail.com'); # SMTP server address
		define('SMTPMAILER_DO_AUTHENTICATE', true); # Turn on SMTP server authentication. Set to false for an anonymous connection
		define('SMTPMAILER_USERNAME', 'abcd.testuser@gmail.com'); # SMTP server username, if SMTPAUTH == true
		define('SMTPMAILER_PASSWORD', 'testing420'); # SMTP server password, if SMTPAUTH == true
		define('SMTPMAILER_CHARSET_ENCODING', 'utf-8'); # E-mails characters encoding, e.g. : 'utf-8' or 'iso-8859-1'
		define('SMTPMAILER_USE_SECURE_CONNECTION', 'tls'); # SMTP encryption method : Set to '' or 'tls' or 'ssl'
		define('SMTPMAILER_SMTP_SERVER_PORT', 587); # SMTP server port. Set to 25 if no encryption or tls. Set to 465 if ssl

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