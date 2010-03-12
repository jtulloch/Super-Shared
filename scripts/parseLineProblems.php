<?php

$fileToDiff = $argv[1];
$outputFileName = $argv[2];
$input = file_get_contents("php://stdin");

$pattern = '/Problem at line ([0-9]*).*: (.*)/';
$matches = array();
preg_match_all( $pattern, $input, $matches, PREG_SET_ORDER);

//print_r($matches);

$sourceFile = file_get_contents($fileToDiff);
$lines = explode("\n", $sourceFile);

$LINE_INDEX = 1;
$MESSAGE_INDEX = 2;
$current_line = 0;
foreach($matches as $problem) {
    $problem_line_index = $problem[$LINE_INDEX] - 1;
    $lines[$problem_line_index] .= " --- " . $problem[$MESSAGE_INDEX];
}

file_put_contents($outputFileName, implode("\n", $lines));

print "Problems found"."\n";
?>
