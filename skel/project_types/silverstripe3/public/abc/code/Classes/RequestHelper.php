<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of RequestHelper
 *
 * @author AzT3k
 */
class RequestHelper {
	
	public static function is_ie() {
	    $u_agent = $_SERVER['HTTP_USER_AGENT'];
	    if (preg_match('/MSIE/i',$u_agent)) return true;
	    else return false;
	}
}

?>
