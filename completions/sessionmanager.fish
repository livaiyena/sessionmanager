# fish shell completions for sessionmanager

# disable file completion by default
complete -c sessionmanager -f

# main commands
complete -c sessionmanager -n "__fish_use_subcommand" -a "monitor" -d "daemon control"
complete -c sessionmanager -n "__fish_use_subcommand" -a "session" -d "sessions"
complete -c sessionmanager -n "__fish_use_subcommand" -a "report" -d "reports"
complete -c sessionmanager -n "__fish_use_subcommand" -a "macro" -d "macros"
complete -c sessionmanager -n "__fish_use_subcommand" -a "whitelist" -d "whitelist"
complete -c sessionmanager -n "__fish_use_subcommand" -a "cleanup" -d "maintenance"

# monitor subcommands
set -l monitor_condition "__fish_seen_subcommand_from monitor; and not __fish_seen_subcommand_from start stop status"
complete -c sessionmanager -n "$monitor_condition" -a "start" -d "start daemon"
complete -c sessionmanager -n "$monitor_condition" -a "stop" -d "stop daemon"
complete -c sessionmanager -n "$monitor_condition" -a "status" -d "daemon status"

# session subcommands
set -l session_condition "__fish_seen_subcommand_from session; and not __fish_seen_subcommand_from start stop current"
complete -c sessionmanager -n "$session_condition" -a "start" -d "start session"
complete -c sessionmanager -n "$session_condition" -a "stop" -d "end session"
complete -c sessionmanager -n "$session_condition" -a "current" -d "show info"

# session start options
complete -c sessionmanager -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l topic -d "topic" -r
complete -c sessionmanager -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l description -d "description" -r
complete -c sessionmanager -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l duration -d "minutes" -r
complete -c sessionmanager -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l macro -d "use macro" -r

# report subcommands
set -l report_condition "__fish_seen_subcommand_from report; and not __fish_seen_subcommand_from daily weekly"
complete -c sessionmanager -n "$report_condition" -a "daily" -d "daily summary"
complete -c sessionmanager -n "$report_condition" -a "weekly" -d "weekly summary"
complete -c sessionmanager -n "__fish_seen_subcommand_from report; and __fish_seen_subcommand_from daily weekly" -l json -d "json output"

# macro subcommands
set -l macro_condition "__fish_seen_subcommand_from macro; and not __fish_seen_subcommand_from list create delete run"
complete -c sessionmanager -n "$macro_condition" -a "list" -d "list macros"
complete -c sessionmanager -n "$macro_condition" -a "create" -d "create macro"
complete -c sessionmanager -n "$macro_condition" -a "delete" -d "delete macro"
complete -c sessionmanager -n "$macro_condition" -a "run" -d "run macro"

# macro create options
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l name -d "name" -r
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l topic -d "topic" -r
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l description -d "description" -r
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l duration -d "minutes" -r

# macro delete/run options
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from delete run" -l name -d "name" -r

# whitelist subcommands
set -l whitelist_condition "__fish_seen_subcommand_from whitelist; and not __fish_seen_subcommand_from list add remove"
complete -c sessionmanager -n "$whitelist_condition" -a "list" -d "list apps"
complete -c sessionmanager -n "$whitelist_condition" -a "add" -d "add app"
complete -c sessionmanager -n "$whitelist_condition" -a "remove" -d "remove app"

# whitelist options
complete -c sessionmanager -n "__fish_seen_subcommand_from whitelist; and __fish_seen_subcommand_from add remove" -l app -d "app class" -r

# cleanup options
complete -c sessionmanager -n "__fish_seen_subcommand_from cleanup" -l days -d "keep days" -r
