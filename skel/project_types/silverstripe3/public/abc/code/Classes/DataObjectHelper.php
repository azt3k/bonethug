<?php

class DataObjectHelper{

	/*
	 *	Stores a cache of the extension Map
	 */
	protected static $extensionMap			= array();
	protected static $dOTableMap			= array();
	protected static $dOExtTableMap			= array();
	protected static $dOExtTablePropertyMap	= array();

	/*
	 *	Returns an array of classnames that have been extended with a Extension
	 */
	public static function getExtendedClasses($extension){

		if ( !count(self::$extensionMap) ) self::generateExtentionMap() ;

		// Return the result
		return empty(self::$extensionMap[$extension]) ? false : self::$extensionMap[$extension];

	}

	/*
	 *	Generates a map of extensions that have been applied to Data Objects
	 */
	private static function generateExtentionMap(){
		$classes = get_declared_classes();
		$extMap = $dOClasses = $dODClasses = array();

		// Sort Classes
		foreach($classes as $class){
			if ( is_subclass_of($class, 'DataObject') ) $dOClasses[] = $class;
			if ( is_subclass_of($class, 'Extension') ) $dODClasses[] = $class;
		}

		// Find out what is applied to what	
		foreach($dODClasses as $dOD){
			foreach($dOClasses as $dO){
				if ( Object::has_extension($dO, $dOD) ) $extMap[$dOD][] = $dO;
			}
		}
		
		// Cache the map
		self::$extensionMap = $extMap;		
	}
	
	/*
	 *	Returns the table name for a given DataObject
	 * 
	 *	@param	(str)	$class	The name of the DataObject
	 * 
	 */	
	public static function getTableForClass($className){

		// If the result is already cached use that
		if (!empty(self::$dOTableMap[$className])) return self::$dOTableMap[$className] ;

		// Find the Table Mapping
		$class = new ReflectionClass($className);
		$lineage = array();
		$i = 0;

		// go through parent classes and look for the one that will have created a db table
		while ($class = $class->getParentClass()) {
			
			$currentClass = $class->getName();

			// Cache and return the table mapping
			if ($currentClass == 'DataObject'){
				$k = $i-1;
				$table = $k < 0 ? $className : $lineage[$k] ;
				self::$dOTableMap[$className] = $table;
				return $table;
			}

			$lineage[] = $currentClass;
			$i++;

		}
		
	}

	/*
	 *	Returns the table created in the add_extension process for a given DataObject
	 * 
	 *	@param	(str)	$class	The name of the DataObject
	 * 
	 */	
	public static function getExtensionTablesForClass($className){

		// If the result is already cached use that
		if (!empty(self::$dOExtTableMap[$className])) return self::$dOExtTableMap[$className] ;
		
		$tables = array();

		//check the current class before proceeding on to the parents
		if (self::tableExists($className)) $tables[] = $className;

		// Look through the parents of the class and find the lowest level class with its own table		
		$class = new ReflectionClass($className);
		while ($class = $class->getParentClass()) {

			// check if the table exists for the current class
			$currentClass = $class->getName();
			if (self::tableExists($currentClass)) $tables[] = $currentClass;

		}
		
		self::$dOExtTableMap[$className] = $tables;
		
		return $tables;
		
	}
	
	/*
	 *	Checks if a table exists for a given classname
	 */	
	public static function tableExists($className){
		
		$result = DB::query("SHOW TABLES LIKE '".Convert::raw2sql($className)."'");
		return $result->numRecords() ? true : false ;

	}
	
	/*
	 *	Finds what table a property for a class exists on
	 */		
	public static function getExtensionTableForClassWithProperty($className,$property){
		
		// If the result is already cached use that
		if (!empty(self::$dOExtTablePropertyMap[$className][$property])) return self::$dOExtTablePropertyMap[$className][$property] ;
		
		// find the Table
		$tables = self::getExtensionTablesForClass($className);

		foreach($tables as $table){
			
			// perform query
			$result = DB::query("SHOW COLUMNS FROM ".Convert::raw2sql($table)." WHERE Field LIKE '".Convert::raw2sql($property)."'");
			
			// Cache and return the result
			if($result->numRecords()){
				self::$dOExtTablePropertyMap[$className][$property] = $table;	
				return $table;
			}
			
		}
		
		return false;
	}	

	/*
	 *	Populates the object with the data found in $data
	 *	-> currently no relation support
	 */
	public static function populate($obj,$data,$populateNonDeclaredProperties = false){
		$fields = $obj->getAllFields();
		foreach($fields as $field){
			if( is_array($data) && ($populateNonDeclaredProperties || array_key_exists($data, $field)) ){
				$obj->$field = $data[$field];
			}elseif( is_object($data) && ($populateNonDeclaredProperties || property_exists($data, $field)) ){
				$obj->$field = $data->$field;
			}
		}
		return $obj;
	}
	
	/*
	 * Gets sub classes of the provided class - possibly should work off the manifest rather than get declared classes
	 */
	public static function getSubclassesOf($parent) {

		return ClassInfo::subclassesFor($parent);

		// $result = array();
		// foreach (get_declared_classes() as $class) {
		// 	if (is_subclass_of($class, $parent))
		// 		$result[] = $class;
		// }
		
	}	

	protected static function getFieldsForObj($obj) {

		$dbFields = array();
		
		// if custom fields are specified, only select these
		$dbFields = $obj->inheritedDatabaseFields();
		
		// add default required fields
		$dbFields = array_merge($dbFields, array('ID'=>'Int'));

		return $dbFields;
	}

	/*
	 *	DataObject to Array
	 */
	public static function DO2Array(DataObject $do, $depth = 1, $exclude = array(), $include = array(), $currentDepth = 0){

		$out = array();

		// Look for includes and excludes on object
		$inclExists = $exclExists = true;
		try{ $do->getIncludeInDump(); }catch(Exception $e){ $inclExists = false; }
		try{ $do->getExcludeFromDump(); }catch(Exception $e){ $exclExists = false; }

		// Process Incl + Excl
		$includeInDump = $inclExists ? $do->getIncludeInDump() : array();
		$excludeFromDump = $exclExists ? $do->getExcludeFromDump() : array();
		$includeInDump = array_unique(array_merge($include, (!empty($includeInDump) && is_array($includeInDump)) ? $includeInDump : array()));
		$excludeFromDump = array_unique(array_merge($exclude, (!empty($excludeFromDump) && is_array($excludeFromDump)) ? $excludeFromDump  : array()));

		// Fields on Obj
		foreach(self::getFieldsForObj($do) as $fieldName => $fieldType){
			if (!in_array($fieldName, $excludeFromDump)) $out[$fieldName] = $do->$fieldName;
		}

		// inclusion
		foreach($includeInDump as $incl){
			$tmp = null;
			try{ 
				$tmp = $do->$incl();
			}catch(Exception $e){
				try{
					$method = 'get'.ucfirst($incl);
					$tmp = $do->$method();
				}catch(Exception $e){
					$tmp = $do->$incl;
				}
			}
			if( $tmp && is_object($tmp) && is_a($tmp, 'DataObjectSet') ){
				if($depth > $currentDepth){
					$r = array();
					foreach($tmp as $item){
						$r[] = self::DO2Array($item, $depth, $exclude, $include, $currentDepth+1);
					}
					$out[$incl] = $r;
				}
			}elseif( $tmp && is_object($tmp) && is_a($tmp, 'DataObject') ){
				$out[$incl] = self::DO2Array($tmp, $depth, $exclude, $include, $currentDepth+1);
			}elseif( $tmp ){
				$out[$incl] = $tmp;
			}			
		}				

		// Relations
		if($depth > $currentDepth){
			if ($do->has_many()) {
				foreach($do->has_many() as $k => $v){
					if(!in_array($k, $excludeFromDump)){
						$r = array();
						foreach($do->$k() as $childK => $childV){
							$r[] = self::DO2Array($childV, $depth, $exclude, $include, $currentDepth+1);					
						}
						$out[$k] = $r;
					}
				}
			}
			if ($do->has_one()) {
				foreach($do->has_one() as $k => $v){
					if (!in_array($k, $excludeFromDump)) $out[$k] = self::DO2Array($do->$k(), $depth, $exclude, $include, $currentDepth+1) ;
				}
			}
			if ($do->many_many()) {
				foreach($do->many_many() as $k => $v){
					if(!in_array($k, $excludeFromDump)){
						$r = array();
						foreach($do->$k() as $childK => $childV){
							$r[] = self::DO2Array($childV, $depth, $exclude, $include, $currentDepth+1);					
						}
						$out[$k] = $r;
					}
				}
			}
		}
		return $out;

	}

	/*
	 *	DataObjectSet to Array
	 */
	public static function DOS2Array(DataObjectSet $dos, $depth = 1, $exclude = array(), $include = array(), $currentDepth = 0){

		$out = array();

		foreach($dos as $do){
			$out[] = self::DO2Array($do, $depth, $exclude, $include, $currentDepth+1);	
		}

		return $out;

	}	

	/*
	 *	DataObject to JSON
	 */
	public static function DO2JSON(DataObject $do, $depth = 1, $exclude = array(), $include = array(), $currentDepth = 0){

		return json_encode(self::DO2Array($do, $depth, $exclude, $include, $currentDepth));

	}

	/*
	 *	DataObjectSet to JSON
	 */
	public static function DOS2JSON(DataObjectSet $dos, $depth = 1, $exclude = array(), $include = array(), $currentDepth = 0){

		return json_encode(self::DOS2Array($dos, $depth, $exclude, $include, $currentDepth));

	}	

}