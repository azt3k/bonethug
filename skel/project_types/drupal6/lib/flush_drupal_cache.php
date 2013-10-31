<?php
$pub_dir = __DIR__ . '/../public';
chdir($pub_dir);
define('DRUPAL_ROOT', $pub_dir);
require_once 'includes/bootstrap.inc';
drupal_bootstrap(DRUPAL_BOOTSTRAP_FULL);
drupal_flush_all_caches();