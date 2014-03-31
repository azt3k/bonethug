<?php

require realpath(__DIR__ . '/../vendor/autoload.php');
require 'drupal_bootstrap.php';

$boris = new \Boris\Boris('drupal> ');
$boris->start();