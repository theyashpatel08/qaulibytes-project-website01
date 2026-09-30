#!/bin/bash
#======================================================
#script name: server_setup.sh
#description: installa node.js and nginx on fresh EC2
#author: yash 
#usage: sudo bash server_setup.sh
#run: only once on a fresh EC2 server
#=======================================================

#stop the script immediately if any command fails
set -e


#color codes for terminal output--
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RES='\033[0m'

#helper functions---
info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[OK]${RESET} $1"; }
error()   { echo -e "${RED}[ERROR]${RESET} $1"; exit 1; }

echo "" #it reprent the blank line
echo "=========================================="
echo "yash - server_setup.sh"
echo "=========================================="
echo ""

#step-1 make sure the script is running as root---
info "Step-1: checking root permissions..."
if [ "$EUID" -ne 0 ]; then
    error "please run with sudo: sudo bash server_setup.sh"
fi
success "running as a root."

#step-2: update system packages----
info "step 2: updating system packages..."
apt update -y > /dev/null 2>&1
apt upgrade -y > /dev/null 2>&1
success "system packages updated."

#step-3: install curl (needed to download node.js setup script)--
info "step 3: installing curl..."
apt install curl -y > /dev/null 2>&1
success "curl installed."

#step-4: install node.js v20 LTS--
info "step 4: installing node.js v20..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash - > /dev/null 2>&1
apt install -y node.js > /dev/null 2>&1
success "node.js $(node --version) and npm $(npm --version) installed."

#step-5: install nginx web server---
info "step 5: installing nginx..."
apt instll nginx -y > /dev/null 2>&1
success "nginx installed."

#step-6: create the web root directory for our app---
info  "step 6: creating web root directory..."
mkdir -p /var/www/qualibytes
chown -R www-data:www-data /var/www/qualibytes
success "web root directory created at /var/www/qualibytes."

#step-7: write the nginx config file---
info "script 7: writing the nginx file.."
cat > /etc/nginx/sites-available/qualibytes << 'EOF'
server {
    listen 80;
    server_name _;
    
    root /var/www/qualibytes;
    index index.html;
    
    #send all routes to index.html (required for react router)
    location / {
        try_files $uri/ /index.html;
    }
}
EOF
Success "nginx config files created."

#step-8: enable the site by creating a symlink--
info "step 8: enabling the site..."
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/qualibytes /etc/nginx/sites-enabled/quaalibytes
success "site enabled."

#step-9: test nginx config, then start it---
info "step 9: starting nginx..."
nginx -t
systemctl start nginx
systemctl enable nginx > /dev/null 2>&1
success "nginx is runnning."

echo ""
echo "==============================================="
echo "server setup COMPLETED!"
echo "==============================================="
echo ""
echo "node.js : $(node --version)"
echo "npm : $(npm --version)"
echo "nginx : $(nginx -v 2>&1)"
echo ""
echo "next step: run deploy.sh to deploy the app."
echo ""