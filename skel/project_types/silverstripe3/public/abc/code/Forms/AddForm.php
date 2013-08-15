<?php

class AbcForm extends Form {

	public static function getSubForms($className = null){

		global $_CLASS_MANIFEST;

		$classes = $_CLASS_MANIFEST;
		$subForms = array();
		if (!$className) $className = get_class();

		// ensure that classes are loaded for comparison
		if (!class_exists($className)) require($classes[strtolower($className)]);

		// Sort Classes
		foreach($classes as $class => $path){

			// generate case sensitve classname
			$pieces = explode('/', $path);
			$csClassName = str_replace('.php','',$pieces[count($pieces)-1]);

			// bypass sapphire classes
			if (stripos($path,'sapphire') === false ) {

				// ensure that classes are loaded for comparison (this wont work for some inbuilt ss classes)
				if ( !class_exists($csClassName) ) try{ require_once($path); }catch(Exception $e){ /* Do Nothing */ }
	 
				// test
				if ( class_exists($csClassName) && is_subclass_of($csClassName, $className) ) $subForms[$csClassName] = preg_replace('/([A-Z])/',' $1',$csClassName);
				
			}
		}

		return $subForms;		
	}

}