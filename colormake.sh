#!/bin/sh

ruby ~/colormake.rb $@
if [ "$?" = 0 ]; then
	play ~/wavs/cow1.wav -q
else
	play ~/wavs/cat_growl.wav -q
fi
