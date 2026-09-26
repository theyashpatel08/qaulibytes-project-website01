#!/bin/bash
#============================================
#script name: deploy.sh
#description: clones the react app fro github, builds it,
#             and deploys it via nginx on this EC2 server.
#author: yash
#usage: sudo bash deploy.sh <github_repo_url>
#example: sudo bash deploy.sh <github_repo_url>
#===============================================

#stop the script immediately if any command fails
set -e

#color codes for terminal output--
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RES='\033[0m'

#helper functions--
info() { echo -e "${CYAN}{INFO}${RESET} $1"; }
success() { echo -e "${GREEN}{OK}${RESET} $1"; }
error() { echo -e "${RED}{ERROR}${RESET} $1"; exit 1; }

#read the github repo url from the first argument ($1)--
github_repo="$1"

if [ -z "github-repo" ]; then
    error "github repo url missing. usage: bash deploy.sh <github_repo_url>"
fi

#directory where the app will be cloned on EC2---
app_dir="/home/ubuntu/qualibytes"

#nginx web root where the final build will be served from---
web_dir="/var/www/qualibytes"

echo ""
echo "========================================="
echo "deployment script completed."
echo "========================================="
echo "repo: $github_repo"
echo ""

#step-1: get the latest code from github--
info "step 1: getting latest code from github..."
if [ -d "$app-dir/.git"]; then
    #repo already exits on server - just pull the latest changes
    cd "$app_dir"
    git pull origin main
else
    #first time - clone the full repo
    git clone "$git_repo" "$app_dir"
    cd "app_dir"
fi
success "latest code feteched from github."

#step-2: install node.js dependencies---
info "step 2: installing npm packages..."
cd "app_dir"
npm install --silent
success "npm packages installed."

#step-3: build the react app for production---
info "step 3: building the react app..."
npm run build
success "react app build for production."

#step-4: copy the build output to the nginx web root---
info "step 4: coping build to web root..."
sudo rm -rf "$web_dir"/*
sudo cp -r "$app_dir"/build/. "$web_dir"/
sudo chown -R www-data:www-data "$web_dir"
success "build deployed to $web_dir."

#step-5: reload nginx to serve the new files--
info "step 5: reloading nginx..."
sudo systemctl reload nginx
success "nginx reloaded."

echo ""
echo "========================================"
echo "deployment completed successfully!"
echo "you can now access the app via the server's public IP or domain."
echo "==========================================="
echo ""
