<?php

$pub_dir = realpath(__DIR__ . '/../public');
chdir($pub_dir);
define('DRUPAL_ROOT', $pub_dir);

if (!file_exists($pub_dir . '/includes/bootstrap.inc')) die('Bootstrap failed');

$_SERVER['REMOTE_ADDR'] 	= '127.0.0.1';
$_SERVER['REQUEST_METHOD']	= 'GET';

require_once $pub_dir . '/includes/bootstrap.inc';
drupal_bootstrap(DRUPAL_BOOTSTRAP_FULL);