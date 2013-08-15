<?php
/*
* Database MySQLDump Class File
* Copyright (c) 2009 by James Elliott
* James.d.Elliott@gmail.com
* GNU General Public License v3 http://www.gnu.org/licenses/gpl.html
*/

$version1 = '1.3.2'; //This Scripts Version.

class MySQLDump {

	public $tables = array();
	public $connected = false;
	public $output;
	public $droptableifexists = false;
	public $mysql_error;
	
	public function connect($host,$user,$pass,$db) {	
		$return = true;
		$conn = @mysql_connect($host,$user,$pass);
		if (!$conn) { $this->mysql_error = mysql_error(); $return = false; }
		$seldb = @mysql_select_db($db);
		if (!$conn) { $this->mysql_error = mysql_error();  $return = false; }
		$this->connected = $return;
		return $return;
	}

	public function list_tables() {
		$return = true;
		if (!$this->connected) { $return = false; }
		$this->tables = array();
		$sql = mysql_query("SHOW TABLES");
		while ($row = mysql_fetch_array($sql)) {
			array_push($this->tables,$row[0]);
		}
		return $return;
	}

	public function list_values($tablename) {
		
		$sql = mysql_query("SELECT * FROM $tablename");
		$this->output .= "\n\n-- Dumping data for table: $tablename\n\n";

		if ($sql){		
			while ($row = mysql_fetch_array($sql)) {
				$broj_polja = count($row) / 2;
				$this->output .= "INSERT INTO `$tablename` VALUES(";
				$buffer = '';
				for ($i=0;$i < $broj_polja;$i++) {
					$vrednost = $row[$i];
					if (!is_integer($vrednost)) { $vrednost = "'".addslashes($vrednost)."'"; } 
					$buffer .= $vrednost.', ';
				}
				$buffer = substr($buffer,0,count($buffer)-3);
				$this->output .= $buffer . ");\n";
			}
		}else{
			$this->output .= "\n\n-- Unable to get data for for table: $tablename\n\n";
		}
	}

	public function dump_table($tablename) {
		$this->output = "";
		$this->get_table_structure($tablename);	
		$this->list_values($tablename);
	}

	public function get_table_structure($tablename) {

		$this->output .= "\n\n-- Dumping structure for table: $tablename\n\n";

		if ($this->droptableifexists) {
			$this->output .= "DROP TABLE IF EXISTS `$tablename`;\nCREATE TABLE `$tablename` (\n";
		} else { 
			$this->output .= "CREATE TABLE `$tablename` (\n";
		}

		$sql = mysql_query("DESCRIBE `$tablename`");
		$this->fields = array();

		if ($sql){
			while ($row = mysql_fetch_array($sql)) {
				// Field Name
				$name = $row[0];
				// Field Type
				$type = $row[1];
				// Null
				$null = $row[2];
				if ( empty($null) || $null == 'NO' ) $null = "NOT NULL";
				if ( $null == 'YES' ) $null = "NULL";
				// Key
				$key = $row[3];
				if ($key == "PRI") { $primary = $name; }
				// Default
				$default = $row[4];
				//extra
				$extra = $row[5];
				if ($extra !== "") { $extra .= ' '; }
				// Output
				$this->output .= "  `$name` $type $null $extra,\n";
			}
			$this->output .= "  PRIMARY KEY  (`$primary`)\n);\n";			
		}else{
			$this->output .= "\n\n-- Unable to get structure for for table: $tablename \n\n";
		}

	}

}
