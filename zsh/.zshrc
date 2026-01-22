export XDG_CONFIG_HOME=$HOME/.config


if [[ -z $TMUX ]];
then
	local pushDotfiles() {
		git -C $HOME/dotfiles add $HOME/dotfiles/*
		git -C $HOME/dotfiles commit -m "autoUpdateDotfiles"
		git -C $HOME/dotfiles push
	}

	local pushKanbanFiles() {
		git -C $HOME/kanban add $HOME/kanban/*
		git -C $HOME/kanban commit -m "autoUpdateKanbanFiles"
		git -C $HOME/kanban push
	}

	(git -C $HOME/dotfiles pull >> /dev/null &)
	(git -C $HOME/kanban pull >> /dev/null &)

	tmux

	(pushDotfiles &)
	(pushKanbanFiles &)

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
export PATH=$PATH:$HOME/.platformio/penv/bin
export PLATFORMIO_INSTALL_ROOT=$HOME/.platformio
alias py=python3
export PYTHONPATH=$HOME/Settingator/src

export PATH=$PATH:$HOME/AppImages/

export EDITOR=$(which nvim)

export FZF_DEFAULT_OPTS="\
  --color=fg:#F24848,fg+:#F24848,bg:-1,bg+:#331215 \
  --color=hl:#29BECC,hl+:#F2D230,info:#3061F2,marker:#29BECC \
  --color=prompt:#29BECC,spinner:#3061F2,pointer:#F24848,header:#4D5A80 \
  --color=border:#631F21,label:#ffffff,query:#29BECC"

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

alias $(cat ~/.histfile | fzf)
