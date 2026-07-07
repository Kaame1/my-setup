# Load LS_COLORS from dircolors for colorized ls output
if test -r ~/.dircolors; and type -q dircolors
    eval (dircolors -c ~/.dircolors | string replace 'setenv' 'set -gx')
end

# Gruvbox Dark syntax colors for Fish shell
set -g fish_color_normal         ebdbb2
set -g fish_color_command        b8bb26      # commands — green
set -g fish_color_keyword        fb4934      # keywords — red
set -g fish_color_quote          d3869b      # strings — pink
set -g fish_color_redirection    83a598      # redirects — blue
set -g fish_color_end            fe8019      # ; and | — orange
set -g fish_color_error          fb4934      # errors — red
set -g fish_color_param          ebdbb2      # parameters — cream
set -g fish_color_option         fabd2f      # options like --flag — yellow
set -g fish_color_comment        928374      # comments — gray
set -g fish_color_selection      --background=3c3836
set -g fish_color_search_match   --background=504945
set -g fish_color_operator       8ec07c      # operators — aqua
set -g fish_color_escape         8ec07c      # escape chars — aqua
set -g fish_color_autosuggestion fabd2f      # autosuggestions — bright yellow
set -g fish_color_cancel         fb4934      # cancel — red
set -g fish_color_cwd            83a598      # current dir — blue
set -g fish_color_user           b8bb26      # username — green
set -g fish_color_host           fabd2f      # hostname — yellow
set -g fish_color_valid_path     --underline

# Pager colors (tab completion menu)
set -g fish_pager_color_completion   ebdbb2
set -g fish_pager_color_description  928374
set -g fish_pager_color_prefix       b8bb26 --bold --underline
set -g fish_pager_color_progress     ebdbb2 --background=3c3836
set -g fish_pager_color_selected_background --background=504945
