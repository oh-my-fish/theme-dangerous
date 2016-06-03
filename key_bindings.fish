set fish_key_bindings fish_vi_key_bindings
bind '#' __dangerous_toggle_symbols
bind -M visual '#' __dangerous_toggle_symbols
bind ' ' __dangerous_toggle_pwd
bind -M visual ' ' __dangerous_toggle_pwd
bind L __dangerous_cd_next
bind H __dangerous_cd_prev
bind m mark
bind M unmark
bind . __dangerous_edit_commandline
bind -M insert \n __dangerous_preexec
bind \n __dangerous_preexec
