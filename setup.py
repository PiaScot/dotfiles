import os
import shutil
import subprocess


def log(message, level="INFO"):
    """ログメッセージを出力"""
    print(f"[{level}] {message}")


def run_command(command, raise_on_error=True):
    """コマンドを実行し、結果を返す"""
    try:
        result = subprocess.run(
            command, shell=True, text=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
        log(f"Command succeeded: {command}")
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        log(f"Command failed: {command}\n{e.stderr}", level="ERROR")
        if raise_on_error:
            raise


def check_command_availability(commands):
    """必要なコマンドがすべて存在するか確認"""
    missing = [cmd for cmd in commands if shutil.which(cmd) is None]
    if missing:
        log(f"Missing commands: {', '.join(missing)}", level="ERROR")
        return False
    return True


def is_wsl():
    """WSL環境かどうかを判定"""
    return "wsl" in os.uname().release.lower()

def backup_and_write_file(file_path, content):
    """ファイルをバックアップして新しい内容を書き込む"""
    backup_path = f"{file_path}.bak"
    try:
        if os.path.exists(file_path):
            shutil.copy(file_path, backup_path)
            log(f"Backup created: {backup_path}")
        with open(file_path, "w") as file:
            file.write(content)
        log(f"File written: {file_path}")
    except Exception as e:
        log(f"Error handling file {file_path}: {e}", level="ERROR")
        raise


def configure_wsl():
    """WSLの設定を適用"""
    wsl_conf_content = """[interop]
appendWindowsPath=false

[network]
generateResolvConf = false
"""
    resolv_conf_content = """nameserver 8.8.8.8
nameserver 8.8.4.4
"""

    backup_and_write_file("/etc/wsl.conf", wsl_conf_content)
    backup_and_write_file("/etc/resolv.conf", resolv_conf_content)
    run_command("sudo chattr +i /etc/resolv.conf")


def install_packages():
    """パッケージをインストール"""
    packages = [
        "build-essential", "zsh", "fd-find", "ripgrep", "eza",
        "zip", "rar", "jq", "fzf", "gh", "cmake", "mold", "libssl-dev"
    ]
    os_release = run_command("grep '^ID=' /etc/os-release | cut -d '=' -f 2")
    if "ubuntu" in os_release:
        run_command(f"sudo apt update && sudo apt install -y {' '.join(packages)}")
        log("Packages installed successfully.")


def install_dotfiles(dotfiles_repo_path, home_dir):
    """dotfilesをインストール"""
    dotfiles = {
        "dot_zshrc": ".zshrc",
        "dot_tmux.conf": ".tmux.conf",
        "dot_config": ".config",
    }

    for src, dest in dotfiles.items():
        src_path = os.path.join(dotfiles_repo_path, src)
        dest_path = os.path.join(home_dir, dest)
        if os.path.isdir(src_path):
            shutil.copytree(src_path, dest_path, dirs_exist_ok=True)
        else:
            shutil.copy(src_path, dest_path)
        log(f"Installed: {src} -> {dest_path}")


def install_third_party_tools():
    """外部ツールをインストール"""
    commands = [
        "curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh",
        "curl -sS https://starship.rs/install.sh | sh",
        "curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz",
        "curl https://mise.run | sh",
        "sudo rm -rf /opt/nvim && sudo tar -C /opt -xzf nvim-linux64.tar.gz && rm -rf ./nvim-linux64.tar.gz"
    ]
    for cmd in commands:
        run_command(cmd, raise_on_error=False)


def main():
    """メイン関数"""
    if not check_command_availability(["git", "curl", "chattr", "wget"]):
        log("Essential commands are missing. Please install them first.", level="ERROR")
        return

    if is_wsl():
        configure_wsl()
        log("WSL configuration completed.")
        log("need to shutdown and restart it distro")


    install_packages()
    install_third_party_tools()

    home_dir = os.path.expanduser("~")
    dotfiles_repo_path = f"{home_dir}/dotfiles"
    if os.path.exists(dotfiles_repo_path):
        install_dotfiles(dotfiles_repo_path, home_dir)
    else:
        log(f"dotfiles repository not found at {dotfiles_repo_path}.", level="ERROR")

    if "bash" in os.environ["SHELL"]:
        os.system(f"chsh -s {shutil.which('zsh')}")


if __name__ == "__main__":
    main()

