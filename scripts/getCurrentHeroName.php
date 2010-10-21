<?php
require_once("getCurrentInfo.php");

$branch_config = getCurrentInfo();

echo "{$branch_config['hero_name']}\n";
exit(0);
?>
