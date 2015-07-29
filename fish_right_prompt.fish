###############################################################################
#
# Prompt theme name:
#   dangerous
#
# Description:
#   a sophisticated theme
#
# Author:
#   Joseph Tannhuber <sepp.tannhuber@yahoo.de>
#
# Sections:
#   -> Functions
#     -> Toggle functions
#     -> Command duration segment
#     -> Git segment
#     -> PWD segment
#   -> Prompt
#
###############################################################################

###############################################################################
# => Functions
###############################################################################

#####################
# => Toggle functions
#####################
function __dangerous_toggle_symbols -d 'Toggles style of symbols, press # in NORMAL or VISUAL mode'
    if [ $symbols_style = 'symbols' ]
        set symbols_style 'numbers'
  else
      set symbols_style 'symbols'
  end
  set pwd_hist_lock true
  commandline -f repaint
end

function __dangerous_toggle_pwd -d 'Toggles style of pwd segment, press space bar in NORMAL or VISUAL mode'
    for i in (seq (count $dangerous_pwdstyle))
        if [ $dangerous_pwdstyle[$i] = $pwd_style ]
            set pwd_style $dangerous_pwdstyle[(expr $i \% (count $dangerous_pwdstyle) + 1)]
            set pwd_hist_lock true
            commandline -f repaint
            break
        end
    end
end

#############################
# => Command duration segment
#############################
function __dangerous_cmd_duration -d 'Displays the elapsed time of last command'
    set_color normal
    set -l seconds ''
    set -l minutes ''
    set -l hours ''
    set -l days ''
    set -l cmd_duration (expr $CMD_DURATION / 1000)
    if [ $cmd_duration -gt 0 ]
        set seconds (expr $cmd_duration \% 68400 \% 3600 \% 60)'s'
        if [ $cmd_duration -ge 60 ]
            set minutes (expr $cmd_duration \% 68400 \% 3600 / 60)'m'
            if [ $cmd_duration -ge 3600 ]
                set hours (expr $cmd_duration \% 68400 / 3600)'h'
                if [ $cmd_duration -ge 68400 ]
                    set days (expr $cmd_duration / 68400)'d'
                end
            end
        end
        set_color $dangerous_colors[3]
        echo -n '❮'
        switch $pwd_style
            case short long
                if [ $last_status -ne 0 ]
                    echo -n (set_color $dangerous_colors[7])' '$days$hours$minutes$seconds(set_color $dangerous_colors[3])' ❮'
                else
                    echo -n (set_color $dangerous_colors[12])' '$days$hours$minutes$seconds(set_color $dangerous_colors[3])' ❮'
                end
        end
    end
end

################
# => Git segment
################
function __dangerous_is_git_ahead_or_behind -d 'Check if there are unpulled or unpushed commits'
    command git rev-list --count --left-right 'HEAD...@{upstream}' ^ /dev/null  | sed 's|\s\+|\n|g'
end

function __dangerous_git_status -d 'Check git status'
    set -l git_status (command git status --porcelain ^/dev/null | cut -c 1-2)
    set -l added (echo -sn $git_status\n | egrep -c "[ACDMT][ MT]|[ACMT]D")
    set -l deleted (echo -sn $git_status\n | egrep -c "[ ACMRT]D")
    set -l modified (echo -sn $git_status\n | egrep -c ".[MT]")
    set -l renamed (echo -sn $git_status\n | egrep -c "R.")
    set -l unmerged (echo -sn $git_status\n | egrep -c "AA|DD|U.|.U")
    set -l untracked (echo -sn $git_status\n | egrep -c "\?\?")
    echo -n $added\n$deleted\n$modified\n$renamed\n$unmerged\n$untracked
end

function __dangerous_is_git_stashed -d 'Check if there are stashed commits'
    command git log --format="%gd" -g $argv 'refs/stash' -- ^ /dev/null | wc -l | tr -d '[:space:]'
end

function __dangerous_prompt_git_symbols -d 'Displays the git symbols'
    set -l is_repo (command git rev-parse --is-inside-work-tree ^/dev/null)
    if [ -z $is_repo ]
        return
    end

    set -l git_ahead_behind (__dangerous_is_git_ahead_or_behind)
    set -l git_status (__dangerous_git_status)
    set -l git_stashed (__dangerous_is_git_stashed)

    if [ (expr $git_status[1] + $git_status[2] + $git_status[3] + $git_status[4] + $git_status[5] + $git_status[6] + $git_stashed) -ne 0 ]
        set_color $dangerous_colors[4]
        echo -n '❮'
        switch $pwd_style
            case long short
                if [ $symbols_style = 'symbols' ]
                    if [ (count $git_ahead_behind) -eq 2 ]
                        if [ $git_ahead_behind[1] -gt 0 ]
                            set_color -o $dangerous_colors[5]
                            echo -n ' ↑'
                        end
                        if [ $git_ahead_behind[2] -gt 0 ]
                            set_color -o $dangerous_colors[5]
                            echo -n ' ↓'
                        end
                    end
                    if [ $git_status[1] -gt 0 ]
                        set_color -o $dangerous_colors[12]
                        echo -n ' +'
                    end
                    if [ $git_status[2] -gt 0 ]
                        set_color -o $dangerous_colors[7]
                        echo -n ' –'
                    end
                    if [ $git_status[3] -gt 0 ]
                        set_color -o $dangerous_colors[10]
                        echo -n ' ✱'
                    end
                    if [ $git_status[4] -gt 0 ]
                        set_color -o $dangerous_colors[8]
                        echo -n ' →'
                    end
                    if [ $git_status[5] -gt 0 ]
                        set_color -o $dangerous_colors[9]
                        echo -n ' ═'
                    end
                    if [ $git_status[6] -gt 0 ]
                        set_color -o $dangerous_colors[4]
                        echo -n ' ●'
                    end
                    if [ $git_stashed -gt 0 ]
                        set_color -o $dangerous_colors[11]
                        echo -n ' ✭'
                    end
                else
                    if [ (count $git_ahead_behind) -eq 2 ]
                        if [ $git_ahead_behind[1] -gt 0 ]
                            set_color $dangerous_colors[5]
                            echo -n ' '$git_ahead_behind[1]
                        end
                        if [ $git_ahead_behind[2] -gt 0 ]
                            set_color $dangerous_colors[5]
                            echo -n ' '$git_ahead_behind[2]
                        end
                    end
                    if [ $git_status[1] -gt 0 ]
                        set_color $dangerous_colors[12]
                        echo -n ' '$git_status[1]
                    end
                    if [ $git_status[2] -gt 0 ]
                        set_color $dangerous_colors[7]
                        echo -n ' '$git_status[2]
                    end
                    if [ $git_status[3] -gt 0 ]
                        set_color $dangerous_colors[10]
                        echo -n ' '$git_status[3]
                    end
                    if [ $git_status[4] -gt 0 ]
                        set_color $dangerous_colors[8]
                        echo -n ' '$git_status[4]
                    end
                    if [ $git_status[5] -gt 0 ]
                        set_color $dangerous_colors[9]
                        echo -n ' '$git_status[5]
                    end
                    if [ $git_status[6] -gt 0 ]
                        set_color $dangerous_colors[4]
                        echo -n ' '$git_status[6]
                    end
                    if [ $git_stashed -gt 0 ]
                        set_color $dangerous_colors[11]
                        echo -n ' '$git_stashed
                    end
                end
                set_color normal
                echo -n (set_color $dangerous_colors[4])' ❮'
        end
    end
end

################
# => PWD segment
################
function __dangerous_prompt_pwd -d 'Displays the present working directory'
    set_color normal
    set -l user_host ' '
    if set -q SSH_CLIENT
        if [ $symbols_style = 'symbols' ]
            switch $pwd_style
                case short
                    set user_host " $USER@"(hostname -s)':'
                case long
                    set user_host " $USER@"(hostname -f)':'
            end
        else
            set user_host " $USER@"(hostname -i)':'
        end
    end
    set_color $dangerous_current_bindmode_color
    if [ (count $dangerous_prompt_error) != 1 ]
        switch $pwd_style
            case short
                echo -n '❮'$user_host(prompt_pwd)' '
            case long
                echo -n '❮'$user_host(pwd)' '
        end
    else
        echo -n "❮ $dangerous_prompt_error "
        set -e dangerous_prompt_error[1]
    end
    set_color $dangerous_current_bindmode_color
    echo -n '❮'
    set_color normal
end

###############################################################################
# => Prompt
###############################################################################

function fish_right_prompt -d 'Write out the right prompt of the dangerous theme'
    echo -n -s (__dangerous_cmd_duration) (__dangerous_prompt_git_symbols) (__dangerous_prompt_pwd)
    set_color normal
end
