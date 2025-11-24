#!/bin/sh
for i in $(tmux ls -f '#{e|==:#{session_attached},0}' -F '#S')
do
	echo "about to kill session ${i}" >> tmux.log
	tmux kill-session -t ${i}
	echo "session ${i} killed" >> tmux.log
done
