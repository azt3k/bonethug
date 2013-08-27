<?php

// Load stuff / set up environment
// -------------------------------

global $project, $databaseConfig;

// parse the config file and env vars
require_once __DIR__ . '/../../lib/ss_loadconf.php';
$ss_cnf = SS_LoadConf::conf();

// Project Specific Settings
$project = 'project';
SSViewer::set_theme('project');


// Env Settings
// ---------------------------

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

		Requirements::javascript('http://www.bugherd.com/sidebarv2.js?apikey=pt0wdpdahlzyroate2lnbg');
		
		break;

	default:
	case 'production':

		Director::set_environment_type("live");

		// Log file
		SS_Log::add_writer(new SS_LogFileWriter(BASE_PATH.'/../log/production.log'), SS_Log::WARN, '<=');

		break;
		
}

// DB
// ---------------------------

$databaseConfig = array(
	"type" 		=> 'MySQLDatabase',
	"server" 	=> $ss_cnf->db->host,
	"username" 	=> $ss_cnf->db->user,
	"password" 	=> $ss_cnf->db->pass,
	"database" 	=> $ss_cnf->db->name,
	"path" 		=> '',
);	
Config::inst()->update('MySQLDatabase', 'connection_charset', 'utf8');


// Mail
// ---------------------------

define('SMTPMAILER_DEFAULT_FROM_NAME', 		$ss_cnf->mail->default_from['name']);
define('SMTPMAILER_DEFAULT_FROM_EMAIL', 	$ss_cnf->mail->default_from['email']);		
define('SMTPMAILER_SMTP_SERVER_ADDRESS',	$ss_cnf->mail->server);
define('SMTPMAILER_DO_AUTHENTICATE', 		$ss_cnf->mail->authenticate);
define('SMTPMAILER_USERNAME', 				$ss_cnf->mail->user);
define('SMTPMAILER_PASSWORD', 				$ss_cnf->mail->pass);
define('SMTPMAILER_CHARSET_ENCODING', 		$ss_cnf->mail->charset_encoding);
define('SMTPMAILER_USE_SECURE_CONNECTION', 	$ss_cnf->mail->secure);
define('SMTPMAILER_SMTP_SERVER_PORT', 		$ss_cnf->mail->port);


// Misc
// ---------------------------

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
