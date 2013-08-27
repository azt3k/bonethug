<?php

/**
 * @todo join is broken  - ss3 changed the way it handles joins
 */
class AbcPaginator extends ViewableData{
	
	public static $defaultPageVar = 'page';
	public static $defaultHitsVar = 'hits';
	public static $defaultInitHitsPerPage = 20;
	public static $defaultPageDisplayRange = 2;	

	public $pageVar;
	public $hitsVar;
	public $initHitsPerPage;
	public $currentPage;
	public $totalPages;	
	public $start;
	public $limit;
	public $unlimitedRowCount;

	/*
	 *	@Param 	$initHitsPerPage 	(int)	Sets the number of hits per page if no hits value can be found in the url
	 *	@Param 	$pageVar 			(str)	The url param that contains the current page
	 *	@Param 	$hitsVar 			(str) 	The url param that contains the number of hits to display in the current result set
	 */
	public function __construct($initHitsPerPage = null, $pageVar = null, $hitsVar = null){

		// requirements
		Requirements::javascript(ABC_PATH.'/javascript/pagination.js');

		// Set up environment
		$this->pageVar 			= $pageVar 		? $pageVar 		: self::$defaultPageVar ;
		$this->hitsVar 			= $hitsVar 			? $hitsVar 			: self::$defaultHitsVar ;
		$this->initHitsPerPage 	= $initHitsPerPage 	? $initHitsPerPage 	: self::$defaultInitHitsPerPage ;

		// Set the Pagination Vars
		$page 	= (empty($_GET[$this->pageVar]) || !is_numeric($_GET[$this->pageVar]) || (int) $_GET[$this->pageVar] < 1) ? 1 						: (int) $_GET[$this->pageVar] ;
		$hits 	= (empty($_GET[$this->hitsVar]) || !is_numeric($_GET[$this->hitsVar]) || (int) $_GET[$this->hitsVar] < 1) ? $this->initHitsPerPage 	: (int) $_GET[$this->hitsVar] ;
		$this->currentPage = $page;
		$this->start = $page == 1 ? 0 : ($hits * ($page-1));
		$this->limit = $hits;
		
		parent::__construct();

	}

	public function HitsSelector($baseURL,$options = null){
		
		$dropdownOptions = array();
		if ( $options && count($options) ){
			foreach($options as $option){
				$dropdownOptions[AbcURL::get($baseURL)->q(array( $this->hitsVar => $option, $this->pageVar => 1))->URL] = $option;
			}
		}else{
			$default = array(12,24,36,48,60);
			foreach($default as $dindex){
				$dropdownOptions[AbcURL::get($baseURL)->q(array( $this->hitsVar => $dindex, $this->pageVar => 1))->URL] = $dindex;
			}
		}
    
        return new DropdownField(
    		$name = 'Hits',
    		$title = ' ',
    		$source = $dropdownOptions,
    		$value = AbcURL::get($baseURL)->q(array( $this->hitsVar => $this->limit, $this->pageVar => 1))->URL
        );		
	}	

	/*
	 *	Static instance getter for getting a new instance for chaining
	 */
	public function get($initHitsPerPage = null, $pageVar = null, $hitsVar = null){
		return new self($initHitsPerPage, $pageVar, $hitsVar);
	}

	/*
	 *	DataObject::get Wrapper
	 */
	public function fetch($callerClass, $filter = "", $sort = "", $join = "", $limit = "", $containerClass = "DataList"){

		// set default limit
		if (!$limit) $limit = $this->start.",".$this->limit;
		
		// fetch unlimited row count
		$unlimitedRowCount = $this->getUnlimitedRowCount($callerClass, $filter, $join);
		$this->unlimitedRowCount = $unlimitedRowCount;

		// prepare DataSet
		if (!$DataSet = DataObject::get($callerClass, $filter, $sort, $join, $limit, $containerClass)) $DataSet = new $containerClass;
		$DataSet->unlimitedRowCount = $unlimitedRowCount;
		$DataSet->Paginator = $this;
		
		return $DataSet;
	}

	/*
	 *	@Todo - Extension table support
	 */
	public static function getUnlimitedRowCount($callerClass, $filter = "", $join = ""){

		// Init some vars
		$oTable = $table = DataObjectHelper::getTableForClass($callerClass);
		if (Object::has_extension($callerClass,'Versioned')) {
			$stage = Versioned::current_stage();
			$table = $oTable.($stage == 'Live' ? '_'.$stage : '');
		}
		$wSQL = "";
		//$sql = "SELECT COUNT(*) as total FROM ".$table;
		$sql = "SELECT COUNT(*) as total FROM ".SS_SITE_DATABASE_NAME.'.'.$table;
		
		// join
		if ($join) $sql.= " ".$join;
		if ($oTable != $callerClass && DataObjectHelper::tableExists($callerClass)) $sql.= " LEFT JOIN ".$callerClass." ON ".$table.".ID = ".$callerClass.".ID";

		// Add caller class filter if its on a shared table
		if ($callerClass != $oTable){
			$wSQL.= $wSQL ? " AND " : " WHERE " ;
			$wSQL.= "(".$table.".ClassName='".$callerClass."'";

			if ($subclasses = DataObjectHelper::getSubclassesOf($callerClass)) {
				foreach($subclasses as $subclass) {
					$wSQL.= " OR ".$table.".ClassName='".$subclass."'";
				}
			}

			$wSQL.= ")";	
		}

		// Filter
		if ($filter){
			$wSQL.= $wSQL ? " AND " : " WHERE " ; 
			$wSQL.= "(".$filter.")";
		}

		//finalise
		$sql.=$wSQL;
		
		return self::getUnlimitedRowCountForSQL($sql);		
	}

	public static function getUnlimitedRowCountForSQL($sql){
		$r = AbcDB::getInstance()->query($sql);
		if ( $r ) return $r->fetch(PDO::FETCH_OBJ)->total;
		
		return false;		
	}

	/*
	 *	Makes Pagination data for the template.
	 * 	NB Next, Last and CurrentPage are reserved keywords
	 */
	public function dataForTemplate($totalHits = null, $pageDisplayRange = null, $baseURL = null, $hitsSelectorOptions = null){

		// check if we have total hits
		if ($totalHits === null) $totalHits = $this->unlimitedRowCount;

		// pageDisplayRange
		if ($pageDisplayRange === null) $pageDisplayRange = self::$defaultPageDisplayRange;

		// init vars
		$this->totalPages = $totalPages = ceil($totalHits/$this->limit);
		$pageLinks	= new DataObject;
		$return 	= new DataObject;

		// init vars
		$pageLinks->FirstPage = $pageLinks->LastPage = $pageLinks->PreviousPage = $pageLinks->NextPage = null;
		$pageLinks->Total = $totalPages;

		// Prep page links
		if ($this->currentPage > 1+$pageDisplayRange)			$pageLinks->FirstPage		= AbcURL::get($baseURL)->q(array('hits'=>$this->limit,'page'=>1))->URL;
		if ($this->currentPage < $totalPages-$pageDisplayRange)	$pageLinks->LastPage		= AbcURL::get($baseURL)->q(array('hits'=>$this->limit,'page'=>$totalPages))->URL;
		if ($this->currentPage != 1)							$pageLinks->PreviousPage 	= AbcURL::get($baseURL)->q(array('hits'=>$this->limit,'page'=>($this->currentPage - 1)))->URL;
		if ($this->currentPage != $totalPages)					$pageLinks->NextPage 		= AbcURL::get($baseURL)->q(array('hits'=>$this->limit,'page'=>($this->currentPage + 1)))->URL;

		// page quick links
		$pageLinks->QuickLinks = new ArrayList;

		// Define the range
		$maxShow = $this->currentPage + $pageDisplayRange;
		$minShow = $this->currentPage - $pageDisplayRange;
		if ($maxShow > $totalPages)				$maxShow = ($totalPages);
		if ($minShow < 1)						$minShow = 1;

		// make links
		for($i = $minShow; $i <= $maxShow; $i++){
			$link = new DataObject;
			$link->PageLink = $i == $this->currentPage ? null : AbcURL::get($baseURL)->q(array('hits'=>$this->limit,'page'=>$i))->URL ;
			$link->PageNum = $i;
			$pageLinks->QuickLinks->push($link);
		}

		// die($totalHits .' vs '. $this->limit);

		// Prep return data
		$return->HitsSelector			= $this->HitsSelector($baseURL,$hitsSelectorOptions);
		$return->TotalHits				= strval($totalHits);
		$return->TotalPages				= strval($totalPages);
		$return->CurrentPageNum			= strval($this->currentPage);
		$return->HitsPerPage			= strval($this->limit);
		$return->PaginatorRequired		= $totalHits <= $this->limit ? false : true ;
		$return->PageLinks				= $pageLinks;
		$return->PageLinks->Paginator	= $this;		

		

		return $return;
	}
	
	public function IsCurrent($pageNum) {
		return $this->currentPage == $pageNum ? true : false ;
	}
	
	public function IsFirst() {
		return $this->IsCurrent(1);
	}
	
	public function IsLast() {
		return $this->IsCurrent($this->totalPages);
	}

}