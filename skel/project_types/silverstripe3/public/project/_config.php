<?php

// --------------------------------- //
// Load stuff / set up environment
// --------------------------------- //

global $project, $databaseConfig;

// parse the config file and env vars
require_once __DIR__ . '/../../lib/ss_loadconf.php';
$ss_cnf = SS_LoadConf::conf();

// Project Specific Settings
$project = 'project';
SSViewer::set_theme('project');


// --------------------------------- //
// Env Settings
// --------------------------------- //

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


// --------------------------------- //
// Allow override in dev and stage mode for testing asset pipeline
// --------------------------------- //

if (!empty($_GET['env']) && (APPLICATION_ENV == 'staging' || APPLICATION_ENV == 'development')) {
	Director::set_environment_type(SS_LoadConf::translate_env($_GET['env']));
}


// --------------------------------- //
// DB
// --------------------------------- //

$databaseConfig = array(
	"type" 		=> 'MySQLDatabase',
	"server" 	=> $ss_cnf->db->host,
	"username" 	=> $ss_cnf->db->user,
	"password" 	=> $ss_cnf->db->pass,
	"database" 	=> $ss_cnf->db->name,
	"path" 		=> '',
);
Config::inst()->update('MySQLDatabase', 'connection_charset', 'utf8');


// --------------------------------- //
// Mail
// --------------------------------- //

SmtpMailer::set_conf($ss_cnf->mail);


// --------------------------------- //
// Misc
// --------------------------------- //

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

// block the default page build
SiteTree::set_create_default_pages(false);
Config::inst()->update('SiteTree', 'create_default_pages', false);


// --------------------------------- //
// Assets
// --------------------------------- //

Requirements::set_write_js_to_body(true);
Requirements::set_combined_files_enabled(true);

// HTML5 Shims
// -----------

$shimRequirements = array(
    'vendor/selectivizr/selectivizr.min.js',
    'vendor/respond/respond.min.js',
    'vendor/modernizr/modernizr.js'
);
Requirements::combine_files('lte-ie8-shims.js',$shimRequirements);
Requirements::process_combined_files(); // forces ss to generate the file regardless of blocking

// CSS
// ---

$cssRequirements = array(
    'themes/project/css/main.css',
    'themes/project/css/typography.css'
);
Requirements::combine_files('application.css', $cssRequirements);

// Primary JS
// ----------

$jsRequirements = array(
    'vendor/jquery/jquery.min.js',
    'project/javascript/main.js',
    'project/javascript/forms.js'
);
Requirements::combine_files('application.js', $jsRequirements);

// Asset loading
// -------------

// block jquery
// block the combined shims + component files so we can lead them manually
RequirementsHelper::require_block(array_merge(
    array(
        'assets/_combinedfiles/lte-ie8-shims.js',
        'framework/thirdparty/jquery/jquery.js'
    ),
    $shimRequirements
));

// dump this into a conditional
Requirements::insertHeadTags('
    <!--[if (gte IE 6)&(lte IE 8)]>
        <script src="/assets/_combinedfiles/lte-ie8-shims.js"></script>
    <![endif]-->
');

// block all front end requirements from the cms
LeftAndMainHelper::require_block(array_merge(
    array(
        'assets/_combinedfiles/application.css',
        'assets/_combinedfiles/application.js',
        'assets/_combinedfiles/lte-ie8-shims.js'
    ),
    $cssRequirements,
    $jsRequirements,
    $shimRequirements
));

// let the cms load its preferred version of jquery
LeftAndMainHelper::require_unblock(array(
    'framework/thirdparty/jquery/jquery.js'
));