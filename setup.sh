#!/bin/bash
echo this will delete all previous dot files!! are you sure you want to install?
echo Type \'y\' to accept otherwise type \'n\'


if [ ! $answer == "y" ]; then
    exit 0
    echo "skipping installation..."
fi

echo ""

echo "installing dependencies"

# Oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

# If needed on other os add ways to install tmux and nvm
if [[ $OSTYPE == 'darwin'* ]]; then
	#Install Tmux
	brew install tmux

	# install nvm
	brew install nvm
fi




SCRIPT_DIR=$(pwd)
echo "Using script dir: $SCRIPT_DIR"
echo "Using home dir: $HOME"

if [ -e $HOME/.config/nvim ]; then
	rm -r $HOME/.config/nvim
	echo "Removing nvim folder"
fi
if [ -e "$HOME/.zshrc" ]; then
	rm $HOME/.zshrc
	echo "Removing zshrc file"
fi
if [ -e "$HOME/.tmux.conf" ]; then
	rm $HOME/.tmux.conf
	echo "Removing tmux file"
fi
if [ -e "$HOME/.p10k.zsh" ]; then
	rm -r $HOME/.p10k.zsh
	echo "Removing p10k folder"
fi

echo "Setting up symbolic links"

ln -s $SCRIPT_DIR/nvim $HOME/.config/nvim
ln -s $SCRIPT_DIR/.zshrc $HOME/.zshrc
ln -s $SCRIPT_DIR/.tmux.conf $HOME/.tmux.conf
ln -s $SCRIPT_DIR/.p10k.zsh $HOME/.p10k.zsh
