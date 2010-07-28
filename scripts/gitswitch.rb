#!/usr/bin/ruby

def has_changes?
    status_string = `git status`
    return (!status_string.include? "working directory clean")
end

def handle_changes
    option = get_choice("Changes detected...Would you like to stash them?",{'y'=>"Stash changes",'r'=>"Revert changes",'m'=>'Move changes to branch'})
    case option
        when 'y'
            stash_changes
        when 'r'
            puts 'Feature not implemented yet'
            exit
        when 'm'
            return
    end
end

def stash_changes
    puts "Please enter a description (default is no message)"
    answer = gets
    answer.chomp!

    if answer.length > 0
        system("git stash save '#{answer}'")
    else
        system("git stash")
    end
end

def change_branches branch_name
    system("git co #{branch_name}")
end

def apply_branch_stash branch_name
    stash_string = `git stash list | grep -i "on #{branch_name}:"`
    stash_string.chomp
    if stash_string.length <= 0
        return
    end

    puts "There are stashed changes for this branch:"
    stash_string.each_line do |line|
        puts "  #{line}"
    end

    puts "Apply stash?  Enter integer value or nothing to skip"
    answer = gets
    answer.chomp!

    if answer.length <= 0
        return
    end

    system("git stash pop stash@{#{answer}}")
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





def usage
    puts "Usage: gitswitch.rb branch_name"
end

if ARGV.length != 1
    usage
    exit 1
end

branch_name = ARGV.pop

if has_changes?
    handle_changes
end

change_branches branch_name

apply_branch_stash branch_name

