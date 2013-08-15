<?php
// jQuery extensions

/*
$server = ( !empty($_SERVER['HTTPS']) || !empty($_SERVER['HTTP_HTTPS']) || (!empty($_SERVER['REQUEST_SCHEME']) && $_SERVER['REQUEST_SCHEME'] == 'https') ? 'https' : 'http').'://'.$_SERVER['HTTP_HOST'];
Requirements::customScript("
	!window.jQuery && document.write(unescape('%3Cscript src=\"".$server.'/'.ADD_PATH.'/javascript/library/jQuery/jquery-1.8.0.min.js'."\"%3E%3C/script%3E'));
");
*/

//Requirements::block(THIRDPARTY_DIR."/jquery/jquery.js");
//Requirements::javascript(ADD_PATH.'/javascript/library/jQuery/jquery.parseParams.js');
//Requirements::javascript(ADD_PATH.'/javascript/library/jQuery/event.drag/jquery.event.drag.js');
//Requirements::javascript(ADD_PATH.'/javascript/library/jQuery/event.drag/jquery.event.drag.live.js');	
//Requirements::javascript(ADD_PATH.'/javascript/library/jquery.drag.touch.js');

// CMS customisations

LeftAndMain::require_javascript(THIRDPARTY_DIR."/jquery/jquery.js");
//LeftAndMain::require_css(ADD_PATH.'/css/cms.css');
//LeftAndMain::require_javascript(ADD_PATH.'/javascript/jquery.cms.js');

