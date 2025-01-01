# 🚀 NeoHtop Auto-Installer for Linux Mint

Because monitoring your system should be pretty AND easy.

## 🤔 What's This?
A one-script solution to get [NeoHtop](https://github.com/Abdenasser/neohtop) running on Linux Mint. No more dependency hell, no more manual builds - just pure, beautiful system monitoring, probably. 

## ✨ Features
- One-command installation
- Handles ALL dependencies (yes, even the annoying ones)
- Sets up Rust, Node.js, and everything in between
- Creates system-wide command access
- Works on fresh Linux Mint installations
- Zero headaches

## 🏃‍♂️ Quick Start
```bash
git clone https://github.com/yourusername/neohtop-mint-installer.git
cd neohtop-mint-installer
chmod +x install-neohtop.sh
./install-neohtop.sh
```

Then just run:
```bash
neohtop
```

## 🛠 What Gets Installed
- Node.js & npm (if not present)
- Rust & Cargo (if not present)
- Essential build tools
- WebKit2GTK and GTK3 dev libraries
- Other required system packages

## 🎨 After Installation
Launch NeoHtop anytime by typing `neohtop` in your terminal. For elevated privileges:
```bash
sudo neohtop
```

## 🐛 Troubleshooting
If something goes wrong, the script will tell you exactly where it failed. The error messages are actually helpful (imagine that!).

## 🤝 Credits
- Original NeoHtop by [Abdenasser](https://github.com/Abdenasser/neohtop)
- This installer script by your truly

## 📝 License
MIT - Go wild!

## 💡 Pro Tip
Pair this with your favorite color scheme and prepare for the most aesthetically pleasing system monitoring experience of your life.
