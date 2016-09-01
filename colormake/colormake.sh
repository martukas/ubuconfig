#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
	PLAYER=afplay       
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
	PLAYER=play
fi

ruby ~/colormake/colormake.rb $@
if [ "$?" = 0 ]; then
	${PLAYER} ~/colormake/cow1.wav
else
	${PLAYER} ~/colormake/cat_growl.wav
fi
