# Bash completion for session_manager.py

_session_manager_completions()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # main commands
    local commands="monitor session report macro whitelist"
    
    # get command context
    local cmd=""
    local subcmd=""
    
    if [ ${COMP_CWORD} -ge 1 ]; then
        cmd="${COMP_WORDS[1]}"
    fi
    
    if [ ${COMP_CWORD} -ge 2 ]; then
        subcmd="${COMP_WORDS[2]}"
    fi
    
    # top level completion
    if [ ${COMP_CWORD} -eq 1 ]; then
        COMPREPLY=( $(compgen -W "${commands}" -- ${cur}) )
        return 0
    fi
    
    # monitor subcommands
    if [ "${cmd}" = "monitor" ] && [ ${COMP_CWORD} -eq 2 ]; then
        COMPREPLY=( $(compgen -W "start stop status" -- ${cur}) )
        return 0
    fi
    
    # session subcommands
    if [ "${cmd}" = "session" ] && [ ${COMP_CWORD} -eq 2 ]; then
        COMPREPLY=( $(compgen -W "start stop current" -- ${cur}) )
        return 0
    fi
    
    # session start options
    if [ "${cmd}" = "session" ] && [ "${subcmd}" = "start" ]; then
        case "${prev}" in
            --topic|--description|--duration)
                return 0
                ;;
            --macro)
                local macros=$(python3 session_manager.py macro list 2>/dev/null | grep -E '^[a-zA-Z]' | cut -d: -f1)
                COMPREPLY=( $(compgen -W "${macros}" -- ${cur}) )
                return 0
                ;;
            *)
                COMPREPLY=( $(compgen -W "--topic --description --duration --macro" -- ${cur}) )
                return 0
                ;;
        esac
    fi
    
    # report subcommands
    if [ "${cmd}" = "report" ] && [ ${COMP_CWORD} -eq 2 ]; then
        COMPREPLY=( $(compgen -W "daily weekly" -- ${cur}) )
        return 0
    fi
    
    # macro subcommands
    if [ "${cmd}" = "macro" ] && [ ${COMP_CWORD} -eq 2 ]; then
        COMPREPLY=( $(compgen -W "list create delete run" -- ${cur}) )
        return 0
    fi
    
    # macro options
    if [ "${cmd}" = "macro" ]; then
        case "${subcmd}" in
            create)
                case "${prev}" in
                    --name|--topic|--description|--duration)
                        return 0
                        ;;
                    *)
                        COMPREPLY=( $(compgen -W "--name --topic --description --duration" -- ${cur}) )
                        return 0
                        ;;
                esac
                ;;
            delete|run)
                case "${prev}" in
                    --name)
                        local macros=$(python3 session_manager.py macro list 2>/dev/null | grep -E '^[a-zA-Z]' | cut -d: -f1)
                        COMPREPLY=( $(compgen -W "${macros}" -- ${cur}) )
                        return 0
                        ;;
                    *)
                        COMPREPLY=( $(compgen -W "--name" -- ${cur}) )
                        return 0
                        ;;
                esac
                ;;
        esac
    fi
    
    # whitelist subcommands
    if [ "${cmd}" = "whitelist" ] && [ ${COMP_CWORD} -eq 2 ]; then
        COMPREPLY=( $(compgen -W "list add remove" -- ${cur}) )
        return 0
    fi
    
    # whitelist options
    if [ "${cmd}" = "whitelist" ]; then
        case "${subcmd}" in
            add)
                case "${prev}" in
                    --app)
                        # get apps from database and desktop files
                        local apps=""
                        local db_path="$HOME/.local/share/sessionmanager/activity.db"
                        
                        if [ -f "$db_path" ]; then
                            apps=$(sqlite3 "$db_path" "SELECT DISTINCT app_class FROM activities ORDER BY app_class" 2>/dev/null)
                        fi
                        
                        # add apps from .desktop files
                        for desktop in /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop; do
                            if [ -f "$desktop" ]; then
                                local app=$(grep -E "^(Name|StartupWMClass)=" "$desktop" 2>/dev/null | cut -d= -f2 | head -1)
                                if [ -n "$app" ]; then
                                    apps="$apps $app"
                                fi
                            fi
                        done
                        
                        COMPREPLY=( $(compgen -W "${apps}" -- ${cur}) )
                        return 0
                        ;;
                    *)
                        COMPREPLY=( $(compgen -W "--app" -- ${cur}) )
                        return 0
                        ;;
                esac
                ;;
            remove)
                case "${prev}" in
                    --app)
                        local whitelist_file="$HOME/.local/share/sessionmanager/whitelist.txt"
                        if [ -f "$whitelist_file" ]; then
                            local apps=$(grep -v '^#' "$whitelist_file" | grep -v '^$')
                            COMPREPLY=( $(compgen -W "${apps}" -- ${cur}) )
                        fi
                        return 0
                        ;;
                    *)
                        COMPREPLY=( $(compgen -W "--app" -- ${cur}) )
                        return 0
                        ;;
                esac
                ;;
        esac
    fi
    
    return 0
}

complete -o nospace -F _session_manager_completions session_manager.py
complete -o nospace -F _session_manager_completions python3\ session_manager.py
complete -o nospace -F _session_manager_completions ./session_manager.py

# completions for the installed binary
complete -o nospace -F _session_manager_completions sessionmanager

# completions for aliases
complete -o nospace -F _session_manager_completions sm
complete -W "start stop status" sm-start
complete -W "start stop status" sm-stop
complete -W "start stop status" sm-status
