<?php
require_once("getCurrentInfo.php");
exec("git branch 2> /dev/null | grep --color=never -e '\* '", $branch_name);
$branch_name = preg_replace("/^\* +/", "", $branch_name[0]);

$branch_configs = getCurrentInfo();

echo "{$branch_configs[$branch_name]['hero_name']}\n";
exit(0);
?>
