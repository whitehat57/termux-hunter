#!/bin/bash
# -------------------------------------------------------------------
# Termux Bug Bounty Aggressive Setup 2025 - Online Installer
# Fokus: Recon + Content Discovery + Vuln Scanning + XSS
# Total ~7-11GB, cocok 6GB+ RAM
# Cara pakai: curl -fsSL https://raw.githubusercontent.com/whitehat57/termux-hunter/main/installer.sh | bash
# -------------------------------------------------------------------

set -e  # Stop on error

# Fungsi pengecekan tools Go
check_go_tools() {
    echo "Mulai pengecekan tools Go..."
    local tools=("subfinder" "httpx" "nuclei" "katana" "dnsx" "naabu" "hakrawler" "gau" "waybackurls" "dalfox" "ffuf")
    local go_bin="$HOME/go/bin"
    
    # Pastikan PATH include go_bin
    if [[ ":$PATH:" != *":$go_bin:"* ]]; then
        echo "Fixing PATH: Tambah $go_bin ke PATH"
        echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.zshrc
        source ~/.zshrc
    fi
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo "✅ $tool sudah terinstall dan di PATH ($(which $tool))"
            "$tool" --version || true  # Tampilkan versi kalau ada
        else
            echo "❌ $tool tidak ditemukan! Mulai reinstall..."
            case "$tool" in
                subfinder) go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest ;;
                httpx) go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest ;;
                nuclei) go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest ;;
                katana) go install -v github.com/projectdiscovery/katana/cmd/katana@latest ;;
                dnsx) go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest ;;
                naabu) go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest ;;
                hakrawler) go install -v github.com/hakluke/hakrawler/cmd/hakrawler@latest ;;
                gau) go install -v github.com/lc/gau/v2/cmd/gau@latest ;;
                waybackurls) go install -v github.com/tomnomnom/waybackurls@latest ;;
                dalfox) go install -v github.com/hahwul/dalfox/v2@latest ;;
                ffuf) go install -v github.com/ffuf/ffuf/v2@latest ;;
            esac
            if command -v "$tool" &> /dev/null; then
                echo "✅ $tool berhasil direinstall!"
            else
                echo "❌ Gagal reinstall $tool. Cek koneksi atau go env."
            fi
        fi
    done
    echo "Pengecekan selesai!"
}

# Mulai setup utama
echo "Mulai update & install base system..."
pkg update -y && pkg upgrade -y
termux-setup-storage
pkg install -y git curl wget zsh neovim python golang nodejs-lts rust binutils build-essential libxml2 libxslt libjpeg-turbo clang make zip unzip jq yq termux-api -y

echo "Setup zsh + oh-my-zsh (opsional tapi nyaman banget)"
chsh -s zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions --quiet
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting --quiet

# Tambahkan ke .zshrc kalau belum ada
grep -q "plugins=(git z zsh-autosuggestions zsh-syntax-highlighting)" ~/.zshrc || sed -i 's/plugins=(git)/plugins=(git z zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
grep -q 'export PATH="$HOME/go/bin:$PATH"' ~/.zshrc || echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

echo "Install ProjectDiscovery tools + ffuf + dalfox + utility populer..."
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/hakluke/hakrawler/cmd/hakrawler@latest
go install -v github.com/lc/gau/v2/cmd/gau@latest
go install -v github.com/tomnomnom/waybackurls@latest
go install -v github.com/hahwul/dalfox/v2@latest
go install -v github.com/ffuf/ffuf/v2@latest

# Utility penting untuk filter & clean
pip install --break-system-packages uro qsreplace gf arjun anew

# Update nuclei templates (minimal dulu, ~800MB-1.5GB)
nuclei -update
nuclei -update-templates

# Jalankan pengecekan tools Go setelah install
check_go_tools

echo "Setup selesai! Restart Termux atau ketik 'source ~/.zshrc'"
echo "Cek storage: df -h"
echo "Contoh workflow: subfinder -d example.com -all | httpx -o alive.txt"
echo "Backup: tar -czf ~/storage/shared/termux-backup.tar.gz ~/.termux ~/go/bin ~/go/pkg ~/nuclei-templates"
