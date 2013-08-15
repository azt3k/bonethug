<?php

// 0 * * * * php /var/www/vhosts/rowingnz/rowing/project/sapphire/cli-script.php dev/tasks/DBBackup > /var/www/vhosts/rowingnz/rowing/project/logs/DBBuild.log

class DBBackup extends BuildTask {
	
	protected $title		= 'DB Backup';
	protected $description 	= 'Creates a data dump';
	protected $enabled 		= true;

	/**
	 * Run the task, and do the business
	 *
	 * @param SS_HTTPRequest $httpRequest 
	 */
	function run($httpRequest) {

		global $databaseConfig;

		// environment type
		Director::set_environment_type("dev");		

		// debug
		ini_set("display_errors","2");
		ERROR_REPORTING(E_ALL);

		/*
		$dbhost 		= $databaseConfig['server'];
		$dbuser 		= $databaseConfig['username'];
		$dbpwd   		= $databaseConfig['password'];
		$dbname  		= $databaseConfig['database'];
		$backupfolder 	= $_SERVER['DOCUMENT_ROOT'].'/db_backups';
		$dumpfile	 	= $backupfolder."/".$dbname."_".date("Y-m-d_H-i-s").".sql";

		if (!is_dir($backupfolder)) mkdir($backupfolder);

		passthru("/usr/bin/mysqldump --opt --host=$dbhost --user=$dbuser --password=$dbpwd $dbname > $dumpfile");

		echo "Created: ".$dumpfile; passthru("tail -1 $dumpfile");	
		*/

		$drop_table_if_exists 	= false; //Add MySQL 'DROP TABLE IF EXISTS' Statement To Output
		$dbhost 				= $databaseConfig['server'];
		$dbuser 				= $databaseConfig['username'];
		$dbpass   				= $databaseConfig['password'];
		$dbname  				= $databaseConfig['database'];
		$backupfolder 			= __DIR__.'/../../db_backups';
		$dumpfile	 			= $backupfolder."/".$dbname."_".date("Y-m-d_H-i-s").".sql";


		$backup = new MySQLDump();
		$backup->droptableifexists = $drop_table_if_exists;
		$backup->connect($dbhost,$dbuser,$dbpass,$dbname); //Connect To Database

		if (!$backup->connected) { die('Error: '.$backup->mysql_error); } //On Failed Connection, Show Error.

		$backup->list_tables(); //List Database Tables.
		$broj = count($backup->tables); //Count Database Tables.
		$output = '';

		echo "found ".$broj." tables \n\n";

		for ($i=0; $i<$broj; $i++) {

			$table_name = $backup->tables[$i]; //Get Table Names.
			$backup->dump_table($table_name); //Dump Data to the Output Buffer.
			$output.= $backup->output;

		}

		if (!is_dir($backupfolder)) mkdir($backupfolder);
		file_put_contents($dumpfile, $output);
		echo "Dumped into ".$dumpfile;
		//echo "<pre>".$output."</pre>";		

	}
	
}