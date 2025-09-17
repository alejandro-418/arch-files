#
# ~/.bashrc
#

# --- If not running interactively, don't do anything ---
[[ $- != *i* ]] && return
alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
export VISUAL=vim
export EDITOR=vim


# --- Aliases ---
alias ff='fastfetch'
alias sd='systemctl poweroff'


# --- Package update once a day ---
UPDATE_STAMP="$HOME/.last_update_check"
TODAY=$(date +%Y-%m-%d)

if [ ! -f "$UPDATE_STAMP" ] || [ "$(cat "$UPDATE_STAMP")" != "$TODAY" ]; then
	echo "pacman & paru updates"
	sudo pacman -Syu && paru -Syu
	echo "$TODAY" > "$UPDATE_STAMP"
fi

# Created by `pipx` on 2025-08-18 19:43:17
export PATH="$PATH:/home/a/.local/bin"
