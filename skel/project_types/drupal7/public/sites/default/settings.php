<?php

// autoloader
require_once  __DIR__ . '/../../../vendor/autoload.php';

// Namespace for yaml
use Symfony\Component\Yaml\Yaml;

// Transfer environmental vars to constants
if (!defined('APPLICATION_ENV')) define('APPLICATION_ENV', getenv('APPLICATION_ENV') ? getenv('APPLICATION_ENV') : "production");

// prep some data
$cnf = Yaml::parse(file_get_contents(__DIR__.'/../../../config/cnf.yml'));
$db = (object) $cnf['dbs']['default'][APPLICATION_ENV];
$apache = $cnf['apache'][APPLICATION_ENV];

// what conf are we using
require APPLICATION_ENV . '.settings.php';