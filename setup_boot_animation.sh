#!/bin/bash
# -------------------------------------------------------------------
# Termux Boot Animation Setup 2025 - Online Installer
# Fokus: ASCII art animasi sederhana + warna (pakai lolcat kalau ada)
# Cara pakai: curl -fsSL https://raw.githubusercontent.com/whitehat57/termux-hunter/main/setup_boot_animation.sh | bash
# Jalankan setelah setup_terminal.sh
# -------------------------------------------------------------------

set -e  # Stop on error

# Install lolcat kalau belum ada (untuk warna rainbow, opsional)
if ! command -v lolcat &> /dev/null; then
    echo "Install lolcat untuk efek warna..."
    pkg install -y ruby
    gem install lolcat
else
    echo "✅ lolcat sudah terinstall"
fi

# ASCII art Grok (adapted from community explorations, cosmic AI theme)
GROK_ASCII=$(cat <<'EOL'
                  🌌🌠✨🌟🌌
                 /         \
                /           \
               /             \
              /               \
             🤖===[ GALACTIC FRAME ]===🌠
            /|      🌟       |       |\
           / |    ⚡️🧠⚡️    |        \
          /  |   /         \ |         \
         /___|__/___________|__________\
        |       |  xAI NEXUS  |         |
        |  🌐   |   ⚙️🔋⚙️   |    🌐   |
        |_______|_____________|_________|
        |   🔹  |   🔷 🔶 🔷   |    🔹   | 
        |_______|_____________|_________|
        |  💾   |  ∞  CORE  ∞ |    🌀   |
        |_______|_____________|_________|
         ||   ||||   ||||   ||||   ||||
         ||   ||||   ||||   ||||   ||||
        /|\  /|\ \  /||\  / | \  /||\
       / | \ / |  \ /|| \ / |  \/ || \
      /  |  /  |   / ||  /  |   \ ||  \
     /___|_/___|__/_____/___|____||___\
    |  ⚡️  |  🌌  |  🔮 |  🌌  |  ⚡️  |
    |______|______|______|______|______|
     ||   ||  || ||  || ||  || ||  ||||
     ||   ||  || ||  || ||  || ||  ||||
    /|\ /|\ /|\ /|\ /||\ /|\ /|\ /||\
   / | X| X| X| X| /|| \X| X| X| /|| \
  /__|__|__|__|__|/____\|__|__|__||___\
  |  💿 | 🔵 | 🔴 | 🟣 | 🔴 | 🔵 | 💿 |
  |_____|_____|_____|_____|_____|_____|
   ||||  ||||  ||||  ||||  ||||  ||||
   ||||  ||||  ||||  ||||  ||||  ||||
  /||\  /||\  /||\  /||\  /||\  /||\
 / || \/ || \/ || \/ || \/ || \/ || \
*--*--*--*--*--*--*--*--*--*--*--*--*
  🌐  💾  🌟  🌀  ⚡️  ∞  🔹  🧠  🌌  ✨
EOL
)

# Fungsi animasi: Tampilkan baris per baris dengan delay
ANIMATION_SCRIPT=$(cat <<'EOL'
# Grok Boot Animation
grok_animation() {
    local ascii_lines=$(echo "$1" | sed 's/\\//g')  # Escape fix kalau perlu
    IFS=$'\n' read -rd '' -a lines <<< "$ascii_lines"
    clear
    for line in "${lines[@]}"; do
        if command -v lolcat &> /dev/null; then
            echo "$line" | lolcat
        else
            echo "$line"
        fi
        sleep 0.05
    done
    echo ""  # Spasi akhir
}
grok_animation "$GROK_ASCII"
EOL
)

# Tambahkan ke .zshrc kalau belum ada
if ! grep -q "grok_animation" ~/.zshrc; then
    echo "Tambah boot animation ke ~/.zshrc..."
    echo "" >> ~/.zshrc
    echo "# Grok Boot Animation by xAI" >> ~/.zshrc
    echo "GROK_ASCII='$(echo "$GROK_ASCII" | sed "s/'/'\\\\''/g")'" >> ~/.zshrc  # Escape single quote
    echo "$ANIMATION_SCRIPT" >> ~/.zshrc
else
    echo "✅ Boot animation sudah ada di ~/.zshrc"
fi

# Reload zshrc
source ~/.zshrc

echo "Setup boot animation selesai!"
echo "Buka ulang Termux untuk lihat efeknya. Kalau terlalu lambat, edit sleep di ~/.zshrc jadi lebih kecil (misal 0.03)."
echo "Kalau mau non-animasi (langsung tampil), hapus loop for & sleep di fungsi grok_animation."
echo "Enjoy your Grok-powered Termux! 🚀"
