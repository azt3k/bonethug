<?php

$pub_dir = realpath(__DIR__ . '/../public');
chdir($pub_dir);
define('DRUPAL_ROOT', $pub_dir);

if (file_exists($pub_dir . '/includes/bootstrap.inc')) {
    require_once $pub_dir . '/includes/bootstrap.inc';
    drupal_bootstrap(DRUPAL_BOOTSTRAP_FULL);
    drupal_flush_all_caches();
}