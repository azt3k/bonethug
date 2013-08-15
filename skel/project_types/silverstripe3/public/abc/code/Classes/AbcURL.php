<?php

class AbcURL{

	public $URL;
	public $originalURL;

	public function __construct($URL = null){
		if (!$URL) $URL = $_SERVER['REQUEST_URI'];
		$this->URL = $URL;
		$this->originalURL = $URL;
	}

	public static function get($URL = null){
		return new self($URL);
	}

	// this is a bit brief but will work until something better is put in place
	public function q(array $data){
		$url = parse_url($this->URL);
		!empty($url['query']) ? parse_str($url['query'],$r) : $r = array() ;
		$data = array_merge($r,$data);
		$url['query'] = http_build_query($data);
		$this->URL = self::buildURL($url);
		return $this;
	}

	public static function buildURL($data){
		$url = "";
		if (!empty($data['scheme'])) 						$url.=$data['scheme']."://";
		if (!empty($data['user']) && !empty($url['pass']))	$url.=$data['user'].":".$url['pass']."@";
		if (!empty($data['host']))							$url.=$data['host'];
		if (!empty($data['path']))							$url.=$data['path'];
		if (!empty($data['query']))							$url.="?".$data['query'];
		if (!empty($data['fragment']))						$url.="#".$data['fragment'];
		return $url;
	}

}