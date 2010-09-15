<?php

function getCurrentInfo() {
    exec("git branch 2> /dev/null | grep --color=never -e '\* '", $branch_name);
    $branch_name = preg_replace("/^\* +/", "", $branch_name[0]);

    // Being executed from root of directory, regardless of where you call git checkout.
    exec("git rev-parse --show-cdup", $git_root_path);
    $git_root_path = $git_root_path[0];
    $git_root_path = realpath($git_root_path);


    // Load the mappings
    $branch_configs = array();
    $config_file_name = "{$git_root_path}/.git/.hero_branch_map";
    if( file_exists($config_file_name) ) {
        $config_file_contents = file_get_contents("{$git_root_path}/.git/.hero_branch_map");
        foreach( explode("\n", trim($config_file_contents)) as $line ) {
            $values = explode(",", trim($line));
            $branch_configs[trim($values[0])] = array(
                'database_name' => trim($values[1]),
                'hero_name' => trim($values[2])
            );
        }
    }

    if( empty($branch_configs[$branch_name]) ) {
        print "WARNING: You do not have any database configuration for branch [{$branch_name}]\n";
        exit(0);
    }

    return $branch_configs;
}

?>
