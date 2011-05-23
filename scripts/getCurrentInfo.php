<?php

function loadGitHeroMap( $config_file_name ) {
    $branch_configs = array();
    $config_file_contents = file_get_contents($config_file_name);
    foreach( explode("\n", trim($config_file_contents)) as $line ) {
        $values = explode(",", trim($line));
        $branch_configs[trim($values[0])] = array(
            'database_name' => trim($values[1]),
            'hero_name' => trim($values[2])
        );
    }

    return $branch_configs;
}

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
        $branch_configs = loadGitHeroMap($config_file_name);
    } else {
        $git_root_path = "{$_ENV['CURVESPACE']}/{$_ENV['CURVEPROJECT']}";
        $config_file_name = "{$git_root_path}/.git/.hero_branch_map";
        if( file_exists($config_file_name) ) {
            $branch_configs = loadGitHeroMap($config_file_name);
        }
    }

    if( !empty($branch_configs[$branch_name]) ) {
        $branch_config = $branch_configs[$branch_name];
    } else if( !empty($branch_configs['default']) ) {
        $branch_config = $branch_configs['default'];
    } else {
        $branch_config = $branch_configs['master'];
    }

    return $branch_config;
}

?>
