<?php

// Define path constant
$path = str_replace('\\', '/', __DIR__);
$path_fragments = explode('/', $path);
$dir_name = $path_fragments[count($path_fragments) - 1];
define('ABC_PATH', $dir_name);

// fallback image
AbcImage::$fallback_image = ABC_PATH.'/images/no-image.jpg';

// Extensions
Object::add_extension('AddGridFieldDetailForm_ItemRequest', 'GridFieldDetailForm_VersionedDataObject_Actions');
Object::add_extension('LeftAndMain', 'AbcLeftAndMainExtension');
Security::add_extension('AbcSecurityExtension');

// Requirements
Requirements::block(THIRDPARTY_DIR."/jquery/jquery.js");
Requirements::javascript(ABC_PATH."/javascript/library/jQuery/jquery-1.10.2.min.js");
LeftAndMainHelper::require_unblock(THIRDPARTY_DIR."/jquery/jquery.js");
LeftAndMainHelper::require_block(ABC_PATH."/javascript/library/jQuery/jquery-1.10.2.min.js");
Requirements::javascript(ABC_PATH."/javascript/library/modernizr-2.6.2.min.js");

// DatePicker config
Object::useCustomClass('DateField_View_JQuery', 'jQueryUIDateField_View');

// // jQuery extensions
// Requirements::javascript(ABC_PATH.'/javascript/library/jQuery/jquery.parseParams.js');
// Requirements::javascript(ABC_PATH.'/javascript/library/jQuery/ui/js/jquery-ui-1.8.23.custom.min.js');
// Requirements::javascript(ABC_PATH.'/javascript/library/jQuery/jquery.ui.touch-punch.min.js');
// Requirements::javascript(ABC_PATH.'/javascript/library/jQuery/jquery.animate.color.js');
// Requirements::javascript(ABC_PATH.'/javascript/library/jQuery/custom-scrollbar/jquery.mousewheel.min.js');
// Requirements::javascript(ABC_PATH.'/javascript/library/jQuery/custom-scrollbar/jquery.mCustomScrollbar.js');
// Requirements::javascript(ABC_PATH.'/javascript/library/jQuery/mobile/jquery.mobile.custom.js');
Requirements::javascript(ABC_PATH.'/javascript/library/jQuery/event.drag/jquery.event.drag.js');
Requirements::javascript(ABC_PATH.'/javascript/library/jQuery/event.drag/jquery.event.drag.live.js');	
Requirements::javascript(ABC_PATH.'/javascript/library/jquery.drag.touch.js');
// Requirements::javascript(ABC_PATH.'/javascript/library/spin.min.js');

// LeftAndMainHelper::require_block(ABC_PATH.'/javascript/library/jQuery/jquery.parseParams.js');
// LeftAndMainHelper::require_block(ABC_PATH.'/javascript/library/jQuery/ui/js/jquery-ui-1.8.23.custom.min.js');
// LeftAndMainHelper::require_block(ABC_PATH.'/javascript/library/jQuery/jquery.ui.touch-punch.min.js');
// LeftAndMainHelper::require_block(ABC_PATH.'/javascript/library/jQuery/jquery.animate.color.js');
// LeftAndMainHelper::require_block(ABC_PATH.'/javascript/library/jQuery/custom-scrollbar/jquery.mousewheel.min.js');
// LeftAndMainHelper::require_block(ABC_PATH.'/javascript/library/jQuery/custom-scrollbar/jquery.mCustomScrollbar.js');
// LeftAndMainHelper::require_block(ABC_PATH.'/javascript/library/jQuery/mobile/jquery.mobile.custom.js');
// LeftAndMainHelper::require_block(ABC_PATH.'/javascript/library/jQuery/event.drag/jquery.event.drag.js');
// LeftAndMainHelper::require_block(ABC_PATH.'/javascript/library/jQuery/event.drag/jquery.event.drag.live.js');	
// LeftAndMainHelper::require_block(ABC_PATH.'/javascript/library/jquery.drag.touch.js');
// LeftAndMainHelper::require_block(ABC_PATH.'/javascript/library/spin.min.js');

// // CSS
// Requirements::css(ABC_PATH.'/javascript/library/jQuery/ui/css/Aristo/Aristo.css');
// Requirements::css(ABC_PATH.'/javascript/library/jQuery/custom-scrollbar/jquery.mCustomScrollbar.css');
// LeftAndMainHelper::require_block(ABC_PATH.'/javascript/library/jQuery/ui/css/Aristo/Aristo.css');

// CMS customisations

//LeftAndMain::require_javascript(THIRDPARTY_DIR."/jquery/jquery.js");
//LeftAndMain::require_css(ABC_PATH.'/css/cms.css');
//LeftAndMain::require_javascript(ABC_PATH.'/javascript/jquery.cms.js');

//$server = ( !empty($_SERVER['HTTPS']) || !empty($_SERVER['HTTP_HTTPS']) || (!empty($_SERVER['REQUEST_SCHEME']) && $_SERVER['REQUEST_SCHEME'] == 'https') ? 'https' : 'http').'://'.$_SERVER['HTTP_HOST'];
//Requirements::customScript("
//	!window.jQuery && document.write(unescape('%3Cscript src=\"".$server.'/'.ABC_PATH.'/javascript/library/jQuery/jquery-1.8.0.min.js'."\"%3E%3C/script%3E'));
//");