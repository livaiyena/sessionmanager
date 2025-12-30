# fish shell completions for sessionmanager

# disable file completion by default
complete -c sessionmanager -f

# main commands
complete -c sessionmanager -n "__fish_use_subcommand" -a "monitor" -d "monitor daemon control"
complete -c sessionmanager -n "__fish_use_subcommand" -a "session" -d "session management"
complete -c sessionmanager -n "__fish_use_subcommand" -a "report" -d "activity reports"
complete -c sessionmanager -n "__fish_use_subcommand" -a "macro" -d "macro management"
complete -c sessionmanager -n "__fish_use_subcommand" -a "whitelist" -d "protected apps management"

# monitor subcommands
set -l monitor_condition "__fish_seen_subcommand_from monitor; and not __fish_seen_subcommand_from start stop status"
complete -c sessionmanager -n "$monitor_condition" -a "start" -d "start monitoring daemon"
complete -c sessionmanager -n "$monitor_condition" -a "stop" -d "stop monitoring daemon"
complete -c sessionmanager -n "$monitor_condition" -a "status" -d "check daemon status"

# session subcommands
set -l session_condition "__fish_seen_subcommand_from session; and not __fish_seen_subcommand_from start stop current"
complete -c sessionmanager -n "$session_condition" -a "start" -d "start work session"
complete -c sessionmanager -n "$session_condition" -a "stop" -d "end current session"
complete -c sessionmanager -n "$session_condition" -a "current" -d "show current session info"

# session start options
complete -c sessionmanager -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l topic -d "session topic" -r
complete -c sessionmanager -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l description -d "session description" -r
complete -c sessionmanager -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l duration -d "duration in minutes" -r
complete -c sessionmanager -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l macro -d "use saved macro" -r

# report subcommands
set -l report_condition "__fish_seen_subcommand_from report; and not __fish_seen_subcommand_from daily weekly"
complete -c sessionmanager -n "$report_condition" -a "daily" -d "daily activity summary"
complete -c sessionmanager -n "$report_condition" -a "weekly" -d "weekly activity summary"

# macro subcommands
set -l macro_condition "__fish_seen_subcommand_from macro; and not __fish_seen_subcommand_from list create delete run"
complete -c sessionmanager -n "$macro_condition" -a "list" -d "list saved macros"
complete -c sessionmanager -n "$macro_condition" -a "create" -d "create new macro"
complete -c sessionmanager -n "$macro_condition" -a "delete" -d "delete macro"
complete -c sessionmanager -n "$macro_condition" -a "run" -d "run saved macro"

# macro create options
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l name -d "macro name" -r
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l topic -d "session topic" -r
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l description -d "session description" -r
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l duration -d "duration in minutes" -r

# macro delete/run options
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from delete run" -l name -d "macro name" -r

# whitelist subcommands
set -l whitelist_condition "__fish_seen_subcommand_from whitelist; and not __fish_seen_subcommand_from list add remove"
complete -c sessionmanager -n "$whitelist_condition" -a "list" -d "list protected applications"
complete -c sessionmanager -n "$whitelist_condition" -a "add" -d "add protected app"
complete -c sessionmanager -n "$whitelist_condition" -a "remove" -d "remove protected app"

# whitelist options
complete -c sessionmanager -n "__fish_seen_subcommand_from whitelist; and __fish_seen_subcommand_from add remove" -l app -d "application class" -r


