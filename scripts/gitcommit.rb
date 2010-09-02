#!/usr/bin/ruby

#Ok, global...who cares
$commit_files = []

def indicator status_line
    status_line[0..1]
end

def filename status_line
    status_line[3..-1].chomp
end

def status status_line
    is_modified?(status_line) ? 'modified' :
        is_new?(status_line) ? 'new' :
            is_deleted?(status_line) ? 'deleted' :
                nil
end

def is_staged? status_line
    (indicator(status_line) == 'M ' || indicator(status_line) == 'A ')
end

def is_modified? status_line
    (indicator(status_line) == 'M ' || indicator(status_line) == ' M')
end

def is_new? status_line
    (indicator(status_line) == '??' || indicator(status_line) == 'A ')
end

def is_deleted? status_line
    indicator(status_line) == 'D '
end

def handle_file status_line
    file_name = filename(status_line)

    if is_new?(status_line)
        handle_new_file(file_name)
    elsif is_modified?(status_line)
        handle_modified_file(file_name, status_line)
    elsif is_deleted?(status_line)
        handle_deleted_file(file_name)
    end
end

def handle_new_file file_name
    complete = false
    while !complete do
        puts ""
        report_warnings(file_name)

        option = get_choice("Commit new file: #{file_name}?",{'y'=>"Add the file",'n'=>"Don't add the file",'v'=>'View the file','x'=>"Delete the file"})

        case option
            when 'y'
                system("git add #{file_name}")
                file_for_commit(file_name);
                complete = true
            when 'n' then complete = true
            when 'v' then system("vim #{file_name}")
            when 'x'
                system("rm #{file_name}")
                complete = true
            else nil
        end
    end
end

def handle_modified_file file_name, status_line
    complete = false
    while !complete do
        puts ""
        report_warnings(file_name)

        option = get_choice("Commit modified file: #{file_name}?",{'y'=>"Commit the file",'n'=>"Don't commit the file",'v'=>'Diff the file','r'=>"Revert the file"})

        case option
            when 'y'
                file_for_commit(file_name)
                complete = true
            when 'n' then complete = true
            when 'v'
                puts 'Diffing file'
                puts("/home/dale/.supershared/scripts/gitvimdiff.sh #{file_name}")
                args = is_staged?(status_line) ? '--cached' : ''
                system("/home/dale/.supershared/scripts/gitvimdiff.sh #{args} #{file_name}")
            when 'r'
                puts "Sorry, revert not implemented.  Select 'n' to skip."
            else nil
        end
    end
end

def handle_deleted_file file_name
    complete = false
    while !complete do
        puts ""

        option = get_choice("Commit deleted file: #{file_name}?",{'y'=>"Commit the file",'n'=>"Don't commit the file"})

        case option
            when 'y'
                file_for_commit(file_name)
                complete = true
            when 'n' then complete = true
            else nil
        end
    end
end

def report_warnings file_name
    key_words = ['XXX', 'debug', 'warn','TODO','wtf','dumpObject']
    changes_grep_command = "git diff #{file_name} | egrep -v '^-' | grep --color=always -i '#{key_words.join('\|')}'"
    
    warnings = `#{changes_grep_command}`
    if warnings.strip != ''
        puts "Possible unfinished changes or debugging found."
        puts warnings
    end
end

def file_for_commit file_name
    $commit_files << file_name
end

def get_choice message, options

    full_options = options.merge( {'h' => 'Print help', 'q' => 'Abort'} )

    complete = false
    while !complete do
        puts "#{message} ("+ full_options.keys.join('/') +")\n"
        answer = gets
        answer.chomp!

        if options.has_key?(answer)
            return answer
        elsif answer == 'q'
            Process.exit
        else
            print_help(full_options)
        end
    end
end

def print_help options
    options.each do |key,value|
        puts "   #{key} - #{value}"
    end
end

def commit_files
    if $commit_files.length <= 0
        return
    end

    msg = "\n"
    msg += "************************************\n"
    msg += "   Commit files is:\n"
    msg += "      "+$commit_files.join("\n      ")+"\n"
    msg += "************************************\n"
    msg += "\n"
    msg += "Commit these items?"

    choice = get_choice(msg, {'y'=>'Commit the files','n'=>'Abort the commit'})

    if choice == 'y'
        system("git commit " + $commit_files.join(" "))
    end
end







puts "Checking for modified files\n"

modifications = `git status --porcelain`

modifications.each_line do |file_modification|
    if status(file_modification) === nil
        puts "Unkown status for modification: "+file_modification.chomp+"\nSkipping file."
        next
    end

    handle_file(file_modification)
end

commit_files

