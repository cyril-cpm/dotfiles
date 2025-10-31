export XDG_CONFIG_HOME=$HOME/.config
export COLOR_MODE='light'

if [[ -z $TMUX ]];
then
	tmux
	exit
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd beep extendedglob nomatch notify
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/cpm/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

eval "$(zoxide init zsh --cmd cd)"

eval "$(starship init zsh)"

export PIO_CONFIGS=$HOME/custom_platformio_ini
export PATH=$HOME/.platformio/penv/bin:$PATH

alias py=python3
export PYTHONPATH=$HOME/Settingator/src


export EDITOR=$(which nvim)

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
alias :q=exit
alias la="ls -a"
alias ll="ls -l"
alias lla="ls -la"
