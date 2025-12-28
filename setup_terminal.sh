#!/bin/bash
# -------------------------------------------------------------------
# Termux Terminal Enhancer Setup 2025 - Online Installer
# Fokus: Theme, alias, tools tambahan seperti tmux, ranger, starship
# Cara pakai: curl -fsSL https://raw.githubusercontent.com/whitehat57/termux-hunter/main/setup_terminal.sh | bash
# Jalankan setelah installer.sh utama
# -------------------------------------------------------------------

set -e  # Stop on error

# Fungsi cek dan install paket kalau belum ada
install_if_missing() {
    local pkg_name="$1"
    if ! pkg list-installed | grep -q "^$pkg_name/"; then
        echo "Install $pkg_name..."
        pkg install -y "$pkg_name"
    else
        echo "✅ $pkg_name sudah terinstall"
    fi
}

echo "Mulai update base system kalau perlu..."
pkg update -y && pkg upgrade -y

# Install tools tambahan untuk terminal
install_if_missing tmux      # Multiplexer session
install_if_missing ranger    # File manager visual
install_if_missing bat       # Cat lebih bagus dengan syntax
install_if_missing fzf       # Fuzzy finder
install_if_missing ripgrep   # Grep lebih cepat (rg)
install_if_missing tree      # Tampilkan direktori tree
install_if_missing htop      # Monitor proses

# Setup starship prompt (lebih modern & cepat dari powerlevel10k di mobile)
if ! command -v starship &> /dev/null; then
    echo "Install starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
else
    echo "✅ Starship sudah terinstall"
fi

# Setup powerlevel10k kalau mau (opsional, uncomment kalau ingin)
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
# echo "Jalankan 'p10k configure' manual setelah ini untuk setup theme"

# Tambah alias berguna untuk bug bounty & umum
grep -q "alias recon=" ~/.zshrc || cat <<EOL >> ~/.zshrc

# Alias untuk bug bounty workflow
alias recon='subfinder -d \$1 -all -silent | dnsx -silent | httpx -silent -title -tech -status-code -o alive_\$1.txt'
alias crawl='cat \$1 | katana -silent | gau | hakrawler | waybackurls | uro | anew urls_\$1.txt'
alias vulnscan='nuclei -l \$1 -t cves/ -t vulnerabilities/ -t misconfiguration/ -c 20 -rl 60 -o nuclei_\$1.txt'
alias xsshunt='dalfox file \$1 --only-poc -b https://yours.xss.ht -o xss_\$1.txt'

# Alias umum terminal
alias ls='ls --color=auto'
alias ll='ls -lah'
alias cat='bat'
alias grep='rg'
alias find='fzf'
alias tm='tmux new -s main'
alias tree='tree -C'
alias htop='htop'
alias update='pkg update && pkg upgrade -y && go install -v github.com/projectdiscovery/...@latest'  # Ganti ... dengan tools
EOL

# Reload zshrc
source ~/.zshrc

echo "Setup terminal enhancer selesai!"
echo "Fitur baru:"
echo "- Starship prompt: Restart Termux untuk lihat perubahan"
echo "- Tmux: Jalankan 'tm' untuk session baru"
echo "- Ranger: Jalankan 'ranger' untuk file manager"
echo "- Alias: Coba 'recon example.com' atau 'll'"
echo "Kalau mau theme lebih lanjut, atur font Termux di app settings (gunakan Nerd Fonts untuk icon bagus)"
echo "Cek storage: df -h"
