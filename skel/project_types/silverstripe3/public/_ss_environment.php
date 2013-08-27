<?php

// parse the config file and env vars
require_once __DIR__ . '/../../lib/ss_loadconf.php';
$ss_cnf = SS_LoadConf::conf();

global $_FILE_TO_URL_MAPPING;
$_FILE_TO_URL_MAPPING[$ss_cnf->public_dir] = $ss_cnf->url;