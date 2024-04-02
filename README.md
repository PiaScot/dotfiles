# WSL2 Ubuntu essential packages for dev
**Windows Terminal**
- ColorScheme
[Kanagawa](https://github.com/rebelot/kanagawa.nvim/blob/master/extras/windows_terminal.json)
[Tokyonight](https://github.com/folke/tokyonight.nvim/tree/main/extras/windows_terminal)
- Fonts
[GoMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/latest/Go-Mono.zip)
[IosvkaTerm Slab Font](https://github.com/ryanoasis/nerd-fonts/releases/latest/IosevkaTermSlab.zip)

**WSL2 Config**
Disable Windows Path and auto generate resolv.conf
```
sudo sh -c  "echo '\n[interop]\nappendWindowsPath=false\n\n[network]\ngenerateResolvConf = false' >> /etc/wsl.conf"
```
Use google DNS to avoid curl timeout Error
```
sudo sh -c "echo nameserver 8.8.8.8 > /etc/resolv.conf"
```
**Builtin Command**
```
sudo apt update && sudo apt upgrade && sudo apt-get install -y zsh build-essential procps curl file git python3-venv pkg-config libssl-dev gh fd-find ripgrep zsh
```
**Utility**
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [fzf](https://github.com/junegunn/fzf)
- [rust](https://rustup.rs/)
- [golang](https://go.dev/)
