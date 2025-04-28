# Clones Git repo
git clone 'https://github.com/sudoAPWH/kickthemout.git'
cd kickthemout

# Installs dependencies (Debian based systems, modify this to your own package manager)
sudo apt update
sudo apt install python3-nmap
sudo apt install python3-scapy
sudo apt install python3-netifaces

# Runs kickthemout.py for the first time
sudo python3 kickthemout.py
