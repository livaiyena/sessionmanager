# Fish shell completions for sessionmanager

# disable file completion by default
complete -c sessionmanager -f

# main commands
complete -c sessionmanager -n "__fish_use_subcommand" -a "monitor" -d "monitor daemon control"
complete -c sessionmanager -n "__fish_use_subcommand" -a "session" -d "session management"
complete -c sessionmanager -n "__fish_use_subcommand" -a "report" -d "activity reports"
complete -c sessionmanager -n "__fish_use_subcommand" -a "macro" -d "macro management"
complete -c sessionmanager -n "__fish_use_subcommand" -a "whitelist" -d "protected apps management"

# monitor subcommands
complete -c sessionmanager -n "__fish_seen_subcommand_from monitor" -a "start" -d "start monitoring daemon"
complete -c sessionmanager -n "__fish_seen_subcommand_from monitor" -a "stop" -d "stop monitoring daemon"
complete -c sessionmanager -n "__fish_seen_subcommand_from monitor" -a "status" -d "check daemon status"

# session subcommands
complete -c sessionmanager -n "__fish_seen_subcommand_from session" -a "start" -d "start work session"
complete -c sessionmanager -n "__fish_seen_subcommand_from session" -a "stop" -d "end current session"
complete -c sessionmanager -n "__fish_seen_subcommand_from session" -a "current" -d "show current session info"

# session start options
complete -c sessionmanager -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l topic -d "session topic"
complete -c sessionmanager -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l description -d "session description"
complete -c sessionmanager -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l duration -d "duration in minutes"
complete -c sessionmanager -n "__fish_seen_subcommand_from session; and __fish_seen_subcommand_from start" -l macro -d "use saved macro"

# report subcommands
complete -c sessionmanager -n "__fish_seen_subcommand_from report" -a "daily" -d "daily activity summary"
complete -c sessionmanager -n "__fish_seen_subcommand_from report" -a "weekly" -d "weekly activity summary"

# macro subcommands
complete -c sessionmanager -n "__fish_seen_subcommand_from macro" -a "list" -d "list saved macros"
complete -c sessionmanager -n "__fish_seen_subcommand_from macro" -a "create" -d "create new macro"
complete -c sessionmanager -n "__fish_seen_subcommand_from macro" -a "delete" -d "delete macro"
complete -c sessionmanager -n "__fish_seen_subcommand_from macro" -a "run" -d "run saved macro"

# macro options
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l name -d "macro name"
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l topic -d "session topic"
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l description -d "session description"
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from create" -l duration -d "duration in minutes"
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from delete" -l name -d "macro name"
complete -c sessionmanager -n "__fish_seen_subcommand_from macro; and __fish_seen_subcommand_from run" -l name -d "macro name"

# whitelist subcommands
complete -c sessionmanager -n "__fish_seen_subcommand_from whitelist" -a "list" -d "list protected applications"
complete -c sessionmanager -n "__fish_seen_subcommand_from whitelist" -a "add" -d "add protected app"
complete -c sessionmanager -n "__fish_seen_subcommand_from whitelist" -a "remove" -d "remove protected app"

# whitelist options
complete -c sessionmanager -n "__fish_seen_subcommand_from whitelist; and __fish_seen_subcommand_from add" -l app -d "application class"
complete -c sessionmanager -n "__fish_seen_subcommand_from whitelist; and __fish_seen_subcommand_from remove" -l app -d "application class"

# completions for sm alias
complete -c sm -f
complete -c sm -n "__fish_use_subcommand" -a "monitor session report macro whitelist"
complete -c sm -n "__fish_seen_subcommand_from monitor" -a "start stop status"
complete -c sm -n "__fish_seen_subcommand_from session" -a "start stop current"
complete -c sm -n "__fish_seen_subcommand_from report" -a "daily weekly"
complete -c sm -n "__fish_seen_subcommand_from macro" -a "list create delete run"
complete -c sm -n "__fish_seen_subcommand_from whitelist" -a "list add remove"
