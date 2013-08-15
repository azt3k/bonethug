<?php

class AbcStr{

	public $str 				= '';
	public $originalStr 		= '';
	public static $wordLimit 	= 50;
	public static $charLimit	= 300;

	public function __construct($str)
	{
		$this->str 			= $str;
		$this->originalStr = $str;
	}

	public static function get($str){
		return new self($str);
	}

	public function limitWords($wordLimit = null, $overflowIndicator = '...')
	{
		if (!$wordLimit) $wordLimit = self::$wordLimit;
		$words = explode(" ",$this->str);
		$this->str = implode(" ",array_splice($words,0,$wordLimit)).$overflowIndicator;
		return $this;	 	
	}

	public function limitChars($charLimit = null, $overflowIndicator = '...')
	{
		if (!$charLimit) $charLimit = self::$charLimit;
		if (strlen($this->str) <= $charLimit) return $this;
		$effectiveLimit = $charLimit - strlen($overflowIndicator);
		$this->str = substr($this->str, 0, $effectiveLimit).$overflowIndicator;
		return $this;	 	
	}	

	public function limitCharsNoDotDot($charLimit = null)
	{
		$this->limitChars($charLimit = null, $overflowIndicator = '');
		return $this;	 	
	}

}