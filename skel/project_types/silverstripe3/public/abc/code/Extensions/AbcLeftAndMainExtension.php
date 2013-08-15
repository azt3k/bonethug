<?php

/**
 * @author AzT3K
 */
class AbcLeftAndMainExtension extends LeftAndMainExtension {
	
	public function init() {
		
		$requirements = LeftAndMainHelper::get_requirements();
		
		foreach ($requirements['block'] as $file) {
			Requirements::block($file[0]);
		}
		
		foreach ($requirements['unblock'] as $file) {
			Requirements::unblock($file[0]);
		}
		
	}	
	
}

