<?php
require_once("getCurrentInfo.php");

$branch_config = getCurrentInfo();

echo "{$branch_config['database_name']}\n";
exit(0);
?>
