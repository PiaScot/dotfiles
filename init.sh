#!/usr/bin/env bash

# now for specilize ubuntu or debian system(using apt package)

install_dotfiles() {
	repo_url="https://github.com/PiaScot/dotfiles"
	git clone $repo_url "$HOME"
	# cp -f "$HOME/dotfiles/dot_zsh" "$HOME/.zshrc"

	test -d "$HOME/config" || mkdir -p "$HOME/config"
	cp -fR "$HOME/dotfiles/dot_config/nvim" "$HOME/.config"
}

install_prezto() {
    # only how to
    # launch zsh
    zsh
    # clone repo
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    # link the repos
    setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
    # set zsh as default sh
    chsh -s #zsh path
}

install_essential_bin() {
	sudo apt update && sudo upgrade && sudo apt-get install -y build-essential procps curl file git python3-venv pkg-config libssl-dev
}


main() {
	init_build_essential_on_ubuntu
    install_dotfiles
}

main
