import shutil
import stat
import os
import subprocess

def install_opensrc_bin():
    # zoxide install just run command
    os.system("curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh")
    os.system("curl -sS https://starship.rs/install.sh | sh")
    os.system("curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz && sudo rm -rf /opt/nvim && sudo tar -C /opt -xzf nvim-linux64.tar.gz")

def has_command(name):
    if shutil.which(name) == None:
        return False
    return True

def is_wsl():
    if "WSL" in os.uname().release:
        return True
    return False

def is_root_user():
    return os.geteuid() == 0

def is_ready():
    essential_bin = ["git", "chattr", "wget", "curl"]
    for bin in essential_bin:
        if has_command(bin):
            return False
    return True

def usage():
    usage_text='''sudo python3 setup.py
need root priviledge to modify /etc/wsl.conf, /etc/resolv.conf
and, <PKG_MANAGER> install [pkgs]
'''
    print(usage_text)

def write_file(file_path, content):
    try:
        with open(file_path, 'w') as file:
            file.write(content)
        print(f"File written: {file_path}")
    except Exception as e:
        print(f"Error writing to {file_path}: {e}")

def backup_file(file_path):
    backup_path = f"{file_path}.bak"
    try:
        if os.path.exists(file_path):
            os.rename(file_path, backup_path)
            print(f"Backup created: {backup_path}")
    except Exception as e:
        print(f"Error creating backup for {file_path}: {e}")

def wsl_settings():
    #settings /etc/wsl.conf, resolv.conf -> added attribute with `attr +i`
    wsl_str = f'''[interop]
appendWindowsPath=false

[network]
generateResolvConf = false
    '''

    resolv_str = f'''nameserver 8.8.8.8
nameserver 8.8.4.4
    '''

    try:
        backup_file("/etc/wsl.conf")
        write_file("/etc/wsl.conf", wsl_str)
        backup_file("/etc/resolv.conf")
        write_file("/etc/resolv.conf", resolv_str)
        os.system("sudo chattr +i /etc/resolv.conf")

    except Exception as e:
        print(f'Error {e}')

    print("Finished wsl settings")

def pkg_download():
    dl_pkgs = ["build-essential", "zsh", "fd-find", "ripgrep", "eza", "zip", "rar", "jq", "fzf", "gh", "cmake", "mold","libssl-dev"]
    result = subprocess.run(
            ['grep', '^ID=', '/etc/os-release'],
            stdout = subprocess.PIPE,
            text=True
            )
    distro = result.stdout.strip().split('=')[1]

    if "ubuntu" in distro:
        # print(f"sudo apt update && sudo apt upgrade && sudo apt install {' '.join(dl_pkgs)}")
        os.system(f"sudo apt update && sudo apt upgrade && sudo apt install {' '.join(dl_pkgs)}")
        return False

def install_dotfiles():
    shutil.copy("./zsh", "../.zshrc")
    shutil.copy("./tmux.conf", "../.tmux.conf")
    if os.path.exists("../config") == False:
        os.makedirs("../.config")
    shutil.copy("./nvim", "../.config/")

def main():
    if is_ready() == False:
        print("Not found git or chattr command")
        return

    if is_root() == False:
        usage()
        return

    if is_wsl():
        wsl_settings()
        print("Finished settings to /etc/wsl.conf and /etc/resolv.conf with Immutable attribute")

    pkg_download()
    install_dotfiles()

