if status is-interactive
	
    # Commands to run in interactive sessions can go here
end
alias vim="nvim"
alias vimdiff="nvim -d"
alias ll="ls -la"
alias l="ls -l"
alias video="mpv --hwdec=auto $1"

function tree3
    tree -d -L 3 -I '.*|node_modules'
end

fish_add_path $HOME/.local/bin
fish_add_path -g /opt/arm-none-eabi-10.3/bin
fish_add_path $HOME/.local/bin

function claude
    # Recolor THIS terminal cream (#FDF5E3 bg, #3c3836 fg) via OSC 11/10, run Claude with a
    # light theme for this session, then restore the colors on any exit. No new window.
    printf '\e]11;#FDF5E3\a'
    printf '\e]10;#3c3836\a'

    # Claude uses the current working directory as the project dir. Decide where to run:
    #   no args            -> default to the claude workspace
    #   first arg is a dir -> cd there (`.` or any path), pass the rest through
    #   otherwise          -> stay in the current dir, pass all args (prompt/flags)
    set -l target ""
    set -l rest $argv
    if test (count $argv) -eq 0
        set target /home/arammatosyan/workspace/claude
    else if test -d $argv[1]
        set target $argv[1]
        set rest $argv[2..-1]
    end

    if test -n "$target"
        if not pushd $target >/dev/null 2>&1
            echo "claude: directory not found: $target" >&2
            printf '\e]110\a'
            printf '\e]111\a'
            return 1
        end
    end

    command claude --settings '{"theme":"light"}' $rest
    set -l ret $status

    test -n "$target"; and popd >/dev/null 2>&1

    printf '\e]110\a'
    printf '\e]111\a'
    return $ret
end
