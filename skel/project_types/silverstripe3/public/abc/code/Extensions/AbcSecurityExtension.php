<?php

/**
 * @author AzT3K
 */
class AbcSecurityExtension extends Extension {
	
	public function onAfterInit() {
		
		$controller		= $this->owner;
		$params			= (object) $controller->getURLParams();
		
		if ($params->Action == 'ping') {
			
			$requirements	= LeftAndMainHelper::get_requirements();

			foreach ($requirements['block'] as $file) {
				Requirements::block($file[0]);
			}

			foreach ($requirements['unblock'] as $file) {
				Requirements::unblock($file[0]);
			}
			
		}
		
	}
	
}

