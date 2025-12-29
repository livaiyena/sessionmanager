# Fish shell completions for session_manager.py

# disable file completion by default
complete -c session_manager.py -f

# main commands
complete -c session_manager.py -n "__fish_use_subcommand" -a "monitor" -d "monitor daemon control"
complete -c session_manager.py -n "__fish_use_subcommand" -a "session" -d "session management"
complete -c session_manager.py -n "__fish_use_subcommand" -a "report" -d "activity reports"
complete -c session_manager.py -n "__fish_use_subcommand" -a "macro" -d "macro management"
complete -c session_manager.py -n "__fish_use_subcommand" -a "whitelist" -d "protected apps management"

# monitor subcommands
complete -c session_manager.py -n "__fish_seen_subcommand_from monitor" -a "start" -d "start monitoring daemon"
complete -c session_manager.py -n "__fish_seen_subcommand_from monitor" -a "stop" -d "stop monitoring daemon"
complete -c session_manager.py -n "__fish_seen_subcommand_from monitor" -a "status" -d "check daemon status"

# session subcommands
complete -c session_manager.py -n "__fish_seen_subcommand_from session" -a "start" -d "start work session"
complete -c session_manager.py -n "__fish_seen_subcommand_from session" -a "stop" -d "end current session"
complete -c session_manager.py -n "__fish_seen_subcommand_from session" -a "current" -d "show current session info"

# session start options
complete -c session_manager.py -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l topic -d "session topic"
complete -c session_manager.py -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l description -d "session description"
complete -c session_manager.py -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l duration -d "duration in minutes"
complete -c session_manager.py -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l macro -d "use saved macro" -a "(python3 (dirname (status -f))/../session_manager.py macro list 2>/dev/null | grep -E '^[a-zA-Z]' | cut -d: -f1)"

# report subcommands
complete -c session_manager.py -n "__fish_seen_subcommand_from report" -a "daily" -d "daily activity summary"
complete -c session_manager.py -n "__fish_seen_subcommand_from report" -a "weekly" -d "weekly activity summary"

# macro subcommands
complete -c session_manager.py -n "__fish_seen_subcommand_from macro" -a "list" -d "list saved macros"
complete -c session_manager.py -n "__fish_seen_subcommand_from macro" -a "create" -d "create new macro"
complete -c session_manager.py -n "__fish_seen_subcommand_from macro" -a "delete" -d "delete macro"
complete -c session_manager.py -n "__fish_seen_subcommand_from macro" -a "run" -d "run saved macro"

# macro create options
complete -c session_manager.py -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l name -d "macro name"
complete -c session_manager.py -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l topic -d "session topic"
complete -c session_manager.py -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l description -d "session description"
complete -c session_manager.py -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l duration -d "duration in minutes"

# macro delete/run options with macro name completion
complete -c session_manager.py -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from delete" -l name -d "macro name" -a "(python3 (dirname (status -f))/../session_manager.py macro list 2>/dev/null | grep -E '^[a-zA-Z]' | cut -d: -f1)"
complete -c session_manager.py -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from run" -l name -d "macro name" -a "(python3 (dirname (status -f))/../session_manager.py macro list 2>/dev/null | grep -E '^[a-zA-Z]' | cut -d: -f1)"

# whitelist subcommands
complete -c session_manager.py -n "__fish_seen_subcommand_from whitelist" -a "list" -d "list protected applications"
complete -c session_manager.py -n "__fish_seen_subcommand_from whitelist" -a "add" -d "add protected app"
complete -c session_manager.py -n "__fish_seen_subcommand_from whitelist" -a "remove" -d "remove protected app"

# function to get application classes from database and desktop files
function __fish_session_manager_apps
    # get apps from database
    set -l db_path ~/.local/share/sessionmanager/activity.db
    if test -f $db_path
        sqlite3 $db_path "SELECT DISTINCT app_class FROM activities ORDER BY app_class" 2>/dev/null
    end
    
    # get apps from .desktop files
    for desktop in /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop
        if test -f $desktop
            grep -E "^(Name|StartupWMClass)=" $desktop 2>/dev/null | cut -d= -f2 | head -1
        end
    end
end

# whitelist add with app completion from database and desktop files
complete -c session_manager.py -n "__fish_seen_subcommand_from whitelist; and __fish_seen_subcommand_from add" -l app -d "application class" -a "(__fish_session_manager_apps)"

# whitelist remove with current whitelist completion
complete -c session_manager.py -n "__fish_seen_subcommand_from whitelist; and __fish_seen_subcommand_from remove" -l app -d "application class" -a "(test -f ~/.local/share/sessionmanager/whitelist.txt; and grep -v '^#' ~/.local/share/sessionmanager/whitelist.txt | grep -v '^$')"

# completions for sm alias
complete -c sm -f
complete -c sm -n "__fish_use_subcommand" -a "monitor session report macro whitelist"
complete -c sm -n "__fish_seen_subcommand_from monitor" -a "start stop status"
complete -c sm -n "__fish_seen_subcommand_from session" -a "start stop current"
complete -c sm -n "__fish_seen_subcommand_from report" -a "daily weekly"
complete -c sm -n "__fish_seen_subcommand_from macro" -a "list create delete run"
complete -c sm -n "__fish_seen_subcommand_from whitelist" -a "list add remove"
