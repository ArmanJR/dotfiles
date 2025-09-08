# ZSH Configuration Cheat Sheet

## 📦 Homebrew & Package Management
```bash
brews                    # List installed packages
brewu                    # Update and upgrade packages
brewc                    # Clean up old versions
brewd                    # Run brew doctor
```

## 🐍 Python & UV
```bash
py script.py            # Run Python script
pip install package     # Install Python package
venv myenv              # Create virtual environment
activate                # Activate venv or .venv
uv run script.py        # Run with UV
uvi myproject           # Initialize UV project
uvs                     # Sync dependencies
uva requests           # Add package with UV
```

## 🐹 Go Development
```bash
gob                     # go build
gor main.go            # go run
got                    # go test
gotv                   # go test -v
gom tidy               # go mod tidy
goi                    # go install
```

## 📦 Node.js & Package Managers
```bash
npmi                   # npm install
npms                   # npm start
npmr dev              # npm run dev
yi                     # yarn install
ys                     # yarn start
pni                    # pnpm install
pns                    # pnpm start
```

## 🐳 Docker
```bash
d ps                   # docker ps
di                     # docker images
drmf container_id     # Force remove container
dspf                  # Force system prune
dc up -d              # docker compose up detached
dcd                   # docker compose down
dcl service_name      # docker compose logs
dce service_name bash # docker compose exec
```

## ☸️ Kubernetes
```bash
k get pods            # kubectl get pods
kgp                   # kubectl get pods
kg svc                # kubectl get services
ka deployment.yaml    # kubectl apply
kl pod_name           # kubectl logs
kei pod_name bash     # kubectl exec interactive
kshell pod_name       # Custom shell function
kctx                  # List/switch contexts
```

## ☁️ Google Cloud
```bash
gc compute instances list  # gcloud compute instances list
gcl                       # gcloud compute instances list
gcs instance_name         # gcloud compute ssh
gcp-project my-project   # Switch GCP project
gcp-auth                 # Authenticate with GCloud
gsutil ls gs://bucket    # List GCS bucket
```

## 🌩️ AWS
```bash
aws-profile prod         # Switch AWS profile
aws-whoami              # Get caller identity
ec2 describe-instances  # AWS EC2 command
s3 ls                   # AWS S3 list
```

## 🏗️ Terraform
```bash
tf init                # terraform init
tfp                    # terraform plan
tfa                    # terraform apply
tfd                    # terraform destroy
tff                    # terraform fmt
```

## 🎯 Git (Enhanced)
```bash
g status               # git status
ga .                   # git add .
gcm "message"          # git commit -m
gp                     # git push
gpl                    # git pull
gd                     # git diff
gl                     # git log --oneline --graph
gb                     # git branch
gco branch_name        # git checkout
gcb feature_branch     # git checkout -b
gst                    # git stash
git-clean-branches     # Clean merged branches
git-recent-branches    # Show recent branches
qcommit "msg"          # Quick add, commit, push
```

## 📝 Editors
```bash
v file.txt             # nvim (alias)
vim file.txt           # nvim (alias)
c .                    # code . (VSCode)
nvim-config            # Edit nvim config
nvim-update            # Update nvim plugins
zshrc                  # Edit .zshrc in nvim
```

## 📁 File Operations & Navigation
```bash
ll                     # Long list with icons
la                     # List all with icons  
lt                     # Tree view
..                     # cd ..
...                    # cd ../..
~                      # cd ~
-                      # cd to previous dir
mkcd newdir            # mkdir and cd
cx script.sh           # chmod +x
755 file               # chmod 755
backup file.txt        # Create timestamped backup
```

## 🔍 Search & Find
```bash
smartfind query        # Smart file search
findreplace old new    # Find and replace in files
grep -r "text" .       # ripgrep search
find . -name "*.js"    # fd search (if available)
fzf-cd                 # Fuzzy find directory
vf                     # Fuzzy find and edit file
gbf                    # Fuzzy find git branch
```

## 🌐 Network & System
```bash
ip                     # Get public IP
localip                # Get local IP
ports                  # List open ports
nettest                # Test network connectivity
speedtest              # Internet speed test
port 3000              # Check/kill process on port
battery                # Battery status
resources              # System resource monitor
```

## 📊 System Information
```bash
cpu                    # Top processes by CPU
mem                    # Top processes by memory
df                     # Disk space
usage /path            # Disk usage analyzer
sysinfo                # System information
cleanup                # Clean system caches
```

## 🗜️ Archives
```bash
extract file.tar.gz    # Extract any archive format
mktar folder           # Create tar.gz
mkzip folder           # Create zip
```

## ⏰ Time & Productivity
```bash
now                    # Current timestamp
timestamp              # Unix timestamp
stopwatch              # Simple stopwatch
pomodoro 25            # 25-minute focus timer
focus on               # Block distracting sites
focus off              # Unblock sites
weather                # Current weather
weather london         # Weather for city
```

## 📝 Text & Data
```bash
json-format            # Format JSON with jq
count file.txt         # Line count (wc -l)
urlencode "text"       # URL encode
urldecode "%20"        # URL decode
genpass 16             # Generate password
uuid                   # Generate UUID
clip                   # Copy to clipboard (pbcopy)
paste                  # Paste from clipboard
pwd-copy               # Copy current path
```

## 🚀 Development Servers
```bash
serve                  # Python HTTP server :8000
serve-php              # PHP server :8000
devserver 3000         # Live reload server
```

## 📝 Notes & Documentation
```bash
note "meeting notes"   # Quick note taking
note                   # Open today's notes
cheat git              # Command cheatsheet
man ls                 # Enhanced man pages
```

## 🏗️ Project Management
```bash
newproject myapp python # Create Python project
newproject webapp web   # Create web project
dev                    # cd ~/Developer
code                   # cd ~/code
dotfiles               # cd ~/code/dotfiles
```

## 🧹 Cleanup & Maintenance
```bash
docker-clean           # Clean Docker resources
docker-nuke            # Remove ALL Docker data
docker-monitor         # Monitor container stats
finddupes /path        # Find duplicate files
reload                 # Reload .zshrc
```

## 📱 macOS Specific
```bash
showfiles              # Show hidden files in Finder
hidefiles              # Hide hidden files in Finder
sleep                  # Put Mac to sleep immediately
```

## 🔧 SSH & Remote
```bash
ssh-add-keys           # Add SSH keys to agent
ssh-copy-key           # Copy SSH key to clipboard
ssh-tunnel 8080 localhost 80 server # SSH tunnel
```

## 📈 Monitoring Functions
```bash
docker-monitor         # Container resource usage
git-stats             # Repository statistics
git-add-interactive   # Interactive git add with fzf
```

## 💡 Utility Functions
```bash
copy-file config.json  # Copy file to clipboard  
paste-file output.txt  # Paste clipboard to file
qr "Hello World"       # Generate QR code
weather               # Current weather
```

---

## 🔥 Pro Tips

- Use **Tab completion** extensively - most commands have intelligent autocompletion
- **FZF Integration**: Many commands work with fuzzy finding (Ctrl+R for history, Ctrl+T for files)
- **Git Workflow**: Use `qcommit` for quick commits, `git-stats` for repo analysis
- **Docker**: Use `docker-clean` regularly, `docker-nuke` for complete reset
- **Focus Mode**: `focus on` blocks distracting websites during work
- **Quick Navigation**: Use `z` (zoxide) instead of `cd` for smart directory jumping

*Print this page and keep it handy for quick reference!*
