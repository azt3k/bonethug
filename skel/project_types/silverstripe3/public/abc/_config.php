<?php

// Define path constant
define('ADD_PATH', str_replace(str_replace('\\','/',$_SERVER['DOCUMENT_ROOT']).'/', "", str_replace('\\','/',__DIR__)) );

// fallback image
AbcImage::$fallback_image = ADD_PATH.'/images/no-image.jpg';

// Extensions
Object::add_extension('AddGridFieldDetailForm_ItemRequest', 'GridFieldDetailForm_VersionedDataObject_Actions');
Object::add_extension('LeftAndMain', 'AbcLeftAndMainExtension');
Security::add_extension('AbcSecurityExtension');

// Requirements
Requirements::block(THIRDPARTY_DIR."/jquery/jquery.js");
Requirements::javascript(ADD_PATH."/javascript/library/jQuery/jquery-1.10.2.min.js");
LeftAndMainHelper::require_unblock(THIRDPARTY_DIR."/jquery/jquery.js");
LeftAndMainHelper::require_block(ADD_PATH."/javascript/library/jQuery/jquery-1.10.2.min.js");

// DatePicker config
Object::useCustomClass('DateField_View_JQuery', 'jQueryUIDateField_View');

// jQuery extensions
Requirements::javascript(ADD_PATH.'/javascript/library/jQuery/jquery.parseParams.js');
Requirements::javascript(ADD_PATH.'/javascript/library/jQuery/ui/js/jquery-ui-1.8.23.custom.min.js');
Requirements::javascript(ADD_PATH.'/javascript/library/jQuery/jquery.ui.touch-punch.min.js');
Requirements::javascript(ADD_PATH.'/javascript/library/jQuery/jquery.animate.color.js');
Requirements::javascript(ADD_PATH.'/javascript/library/jQuery/custom-scrollbar/jquery.mousewheel.min.js');
Requirements::javascript(ADD_PATH.'/javascript/library/jQuery/custom-scrollbar/jquery.mCustomScrollbar.js');
Requirements::javascript(ADD_PATH.'/javascript/library/jQuery/mobile/jquery.mobile.custom.js');
Requirements::javascript(ADD_PATH.'/javascript/library/jQuery/event.drag/jquery.event.drag.js');
Requirements::javascript(ADD_PATH.'/javascript/library/jQuery/event.drag/jquery.event.drag.live.js');	
Requirements::javascript(ADD_PATH.'/javascript/library/jquery.drag.touch.js');
Requirements::javascript(ADD_PATH.'/javascript/library/spin.min.js');

LeftAndMainHelper::require_block(ADD_PATH.'/javascript/library/jQuery/jquery.parseParams.js');
LeftAndMainHelper::require_block(ADD_PATH.'/javascript/library/jQuery/ui/js/jquery-ui-1.8.23.custom.min.js');
LeftAndMainHelper::require_block(ADD_PATH.'/javascript/library/jQuery/jquery.ui.touch-punch.min.js');
LeftAndMainHelper::require_block(ADD_PATH.'/javascript/library/jQuery/jquery.animate.color.js');
LeftAndMainHelper::require_block(ADD_PATH.'/javascript/library/jQuery/custom-scrollbar/jquery.mousewheel.min.js');
LeftAndMainHelper::require_block(ADD_PATH.'/javascript/library/jQuery/custom-scrollbar/jquery.mCustomScrollbar.js');
LeftAndMainHelper::require_block(ADD_PATH.'/javascript/library/jQuery/mobile/jquery.mobile.custom.js');
LeftAndMainHelper::require_block(ADD_PATH.'/javascript/library/jQuery/event.drag/jquery.event.drag.js');
LeftAndMainHelper::require_block(ADD_PATH.'/javascript/library/jQuery/event.drag/jquery.event.drag.live.js');	
LeftAndMainHelper::require_block(ADD_PATH.'/javascript/library/jquery.drag.touch.js');
LeftAndMainHelper::require_block(ADD_PATH.'/javascript/library/spin.min.js');

// CSS
Requirements::css(ADD_PATH.'/javascript/library/jQuery/ui/css/Aristo/Aristo.css');
Requirements::css(ADD_PATH.'/javascript/library/jQuery/custom-scrollbar/jquery.mCustomScrollbar.css');
LeftAndMainHelper::require_block(ADD_PATH.'/javascript/library/jQuery/ui/css/Aristo/Aristo.css');

// CMS customisations

//LeftAndMain::require_javascript(THIRDPARTY_DIR."/jquery/jquery.js");
//LeftAndMain::require_css(ADD_PATH.'/css/cms.css');
//LeftAndMain::require_javascript(ADD_PATH.'/javascript/jquery.cms.js');

//$server = ( !empty($_SERVER['HTTPS']) || !empty($_SERVER['HTTP_HTTPS']) || (!empty($_SERVER['REQUEST_SCHEME']) && $_SERVER['REQUEST_SCHEME'] == 'https') ? 'https' : 'http').'://'.$_SERVER['HTTP_HOST'];
//Requirements::customScript("
//	!window.jQuery && document.write(unescape('%3Cscript src=\"".$server.'/'.ADD_PATH.'/javascript/library/jQuery/jquery-1.8.0.min.js'."\"%3E%3C/script%3E'));
//");