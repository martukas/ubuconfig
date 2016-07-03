#!/bin/sh

ruby ~/colormake/colormake.rb $@
if [ "$?" = 0 ]; then
	play ~/colormake/cow1.wav -q
else
	play ~/colormake/cat_growl.wav -q
fi
