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

export PIO_CONFIGS=$HOME/custom_platformio_ini
export PATH=$HOME/.platformio/penv/bin:$PATH

alias py=python3
export PYTHONPATH=$HOME/Settingator/src


export EDITOR=$(which nvim)
