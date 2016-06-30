echo "------------------------"
echo "---==================---"
echo "---=== UBU CONFIG ===---"
echo "---==================---"
echo "------------------------"

read -r -p "Install disk tools? [Y/n]" disk
disk=${disk,,} # tolower

read -r -p "Install multimedia players? [Y/n]" mult
mult=${mult,,} # tolower

echo "Email for github ssh key: "
read email
email=${email,,} # tolower

sudo apt-get -y install synaptic guake gedit geany basex bless sox gdb git xclip chromium-browser dosbox

cp -R ./.* ~/
cp -R ./wavs ~/
cp -R ./colormake* ~/

if [[ $mult =~ ^(yes|y| ) ]]; then
  sudo apt-get -y install vlc qmmp clementine
fi

if [[ $disk =~ ^(yes|y| ) ]]; then
  sudo apt-get -y install gparted baobab
fi

ssh-keygen -t rsa -b 4096 -C "$email"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
xclip -sel clip < ~/.ssh/id_rsa.pub
read -p "Please paste contents of clipboard to add key to github account and press key to continue when done..." -n1 -s
ssh -T git@github.com

sudo apt-get -y install curl
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable --ruby --auto-dotfiles
read -p "Please restart shell and run: gem install colorize" -n1 -s

#exec bash
#gem install colorize

