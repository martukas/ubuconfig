# ubuconfig
Environment config script for my preferences in Ubuntu

The script to run is ubuconfig.sh

* Replaces  bashrc and all that stuff, so best do it on a fresh system and later customize it as your own.

* Install the colorized make (mk) script, with cow/cat response for compilation result.
As prerequisites, it will install sox for sound playback, ruby version manager, and latest verison of ruby.
You will manually need to install the colorize gem after restarting console. 

* Installs guake and preferred settings for appearance and behavior, etc.., makes it autostart.

* Sets up ssh public key, adds it to ssh-agent, copies to clipboard for you to add to github. If running in VM, make sure you have shared clipboard or can log into github inside VM.

* Installs these packages:
-synaptic
-guake
-gedit
-geany
-basex
-bless
-sox
-gdb
-git
-xclip
-chromium-browser
-dosbox

* If you agree to "disk tools", it will also install:
-gparted
-baobab

* If you agree to "multimedia players", it will also install:
-qmmp
-clementine
-vlc


