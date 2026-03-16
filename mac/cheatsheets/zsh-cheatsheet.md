# ZSH Configuration Cheat Sheet

## Homebrew & Package Management
```bash
brews                    # List installed packages
brewu                    # Update and upgrade packages
brewc                    # Clean up old versions
brewd                    # Run brew doctor
```

## Python & UV
```bash
py script.py            # Run Python script
activate                # Activate venv or .venv
uvr script.py           # uv run
uvi myproject           # uv init
uvs                     # uv sync
uva requests            # uv add
uvd requests            # uv remove
uvp 3.12               # uv python install
venv myenv              # Create virtual environment
venva                   # Activate venv/.venv
venvd                   # Deactivate venv
```

## Go Development
```bash
gob                    # go build
gor main.go            # go run
got                    # go test
gotv                   # go test -v
gomt                   # go mod tidy
goi                    # go install
```

## Rust Development
```bash
cr                     # cargo run
cb                     # cargo build
ct                     # cargo test
cck                    # cargo check
cf                     # cargo fmt
cl                     # cargo clippy
```

## Node.js & Package Managers
```bash
npmi                   # npm install
npms                   # npm start
npmr dev               # npm run dev
yi                     # yarn install
ys                     # yarn start
yb                     # yarn build
pni                    # pnpm install
pns                    # pnpm start
pnb                    # pnpm build
```

## Docker
```bash
d ps                  # docker ps
di                    # docker images
drmf container_id     # Force remove container
dspf                  # Force system prune
dc up -d              # docker compose up detached
dcd                   # docker compose down
dclf service_name     # docker compose logs -f
dce service_name bash # docker compose exec
docker-clean          # Prune system, volumes, networks
docker-stop-all       # Stop all running containers
docker-nuke           # Remove ALL Docker data (interactive)
docker-monitor        # Container resource usage
```

## Kubernetes
```bash
k get pods            # kubectl get pods
kgp                   # kubectl get pods
kgs                   # kubectl get services
kgd                   # kubectl get deployments
ka deployment.yaml    # kubectl apply
kdel resource         # kubectl delete
kl pod_name           # kubectl logs
klf pod_name          # kubectl logs -f
kei pod_name bash     # kubectl exec interactive
kshell pod_name       # Custom shell function
kctx                  # List/switch contexts
kns my-namespace      # Set current namespace
```

## Google Cloud
```bash
gcp project list       # gcloud (lazy loaded)
gcpe instances list    # gcloud compute
gcpl                   # gcloud compute instances list
gcps instance_name     # gcloud compute ssh
gcp-project my-proj   # Switch GCP project
gcp-auth              # Authenticate with GCloud
gsutil ls gs://bucket  # List GCS bucket
gbq                   # BigQuery CLI
```

## AWS
```bash
aws-profile prod        # Switch AWS profile
aws-whoami              # Get caller identity
ec2 describe-instances  # AWS EC2 command
s3 ls                   # AWS S3 list
```

## Terraform & IaC
```bash
tfi                    # terraform init
tfp                    # terraform plan
tfa                    # terraform apply
tfd                    # terraform destroy
tff                    # terraform fmt
tfs                    # terraform show
tfo                    # terraform output
tgi                    # terragrunt init (if installed)
pulu                   # pulumi up
pulp                   # pulumi preview
```

## Git
```bash
gs                     # git status
ga .                   # git add .
gcm "message"          # git commit -m
gca "message"          # git commit -am
gp                     # git push
gpl                    # git pull
gd                     # git diff
gdc                    # git diff --cached
gl                     # git log --oneline --graph
gla                    # git log --oneline --graph --all
gb                     # git branch
gco branch_name        # git checkout
gcb feature_branch     # git checkout -b
gm branch             # git merge
gr branch             # git rebase
gst                    # git stash
gstp                   # git stash pop
qcommit "msg"          # Quick add, commit, optional push
git-clean-branches     # Clean merged branches
git-recent-branches    # Show recent branches
git-stats              # Repository statistics
git-add-interactive    # Interactive git add with fzf
gi python,node,macos   # Generate .gitignore from gitignore.io
```

## Editors
```bash
v file.txt             # nvim
vim file.txt           # nvim
co .                   # code . (VSCode)
nvim-config            # Edit nvim config
nvim-update            # Update nvim plugins
nvim-health            # Run nvim health check
zshrc                  # Edit .zshrc in nvim
zshconfig              # Edit .zsh/ dir in nvim
```

## AI Tools
```bash
cc                     # Claude Code
ccskip                 # Claude Code (skip permissions)
ccmcp c7 <key>         # Install Context7 MCP tool
codexskip              # Codex (bypass approvals)
```

## File Operations & Navigation
```bash
l                      # eza -lh
ll                     # eza -l --git
la                     # eza -la --git
lt                     # eza -T (tree)
..                     # cd ..
...                    # cd ../..
~                      # cd ~
-                      # cd to previous dir
z <query>              # zoxide (smart cd)
mkcd newdir            # mkdir and cd
cx script.sh           # chmod +x
755 file               # chmod 755
backup file.txt        # Create timestamped backup
catc file.txt          # Copy file contents with filename to clipboard
catingest              # Run gitingest and copy to clipboard
```

## Search & Find
```bash
smartfind query        # Smart file search (fd/find)
findreplace old new    # Find and replace in files
findreplace -n old new # Dry-run find and replace
grep "text" .          # ripgrep (aliased)
find "*.js"            # fd (aliased)
cdf                    # fzf: fuzzy cd into directory
vf                     # fzf: fuzzy find and edit file
gbf                    # fzf: fuzzy checkout git branch
```

## Shell History (Atuin)
```bash
Ctrl+R                 # Search shell history with Atuin
```

## Network & System
```bash
ip                     # Get public IP
localip                # Get local IP
ports                  # List listening ports
nettest                # Test network connectivity
port 3000              # Check/kill process on port
resources              # System resource monitor
psg process_name       # ps aux | grep
parp                   # Pretty ARP table
```

## System Information
```bash
cpu                    # Top processes by CPU
mem                    # Top processes by memory
df                     # Disk space
usage /path            # Disk usage analyzer (ncdu/dust/du)
sysinfo                # System profiler info
cleanup                # Clean system caches (interactive)
```

## Archives
```bash
extract file.tar.gz    # Extract any archive format
mktar folder           # Create tar.gz
mkzip folder           # Create zip
```

## Time & Productivity
```bash
now                    # Current timestamp
nowutc                 # Current UTC timestamp
timestamp              # Unix timestamp
week                   # Current week number
stopwatch              # Simple stopwatch
pomodoro 25            # 25-minute focus timer
focus on               # Block distracting sites
focus off              # Unblock sites
```

## Text & Data
```bash
json-format            # Format JSON with jq
json-compact           # Compact JSON with jq
count file.txt         # Line count (wc -l)
urlencode "text"       # URL encode
urldecode "%20"        # URL decode
genpass 16             # Generate password
uuid                   # Generate UUID
```

## Clipboard
```bash
clip                   # Alias for pbcopy
paste                  # Alias for pbpaste
pwd-copy               # Copy current path
copy-file config.json  # Copy file to clipboard
paste-file output.txt  # Paste clipboard to file
```

## Media Download
```bash
ytmp4 <url>            # Download video as mp4 (yt-dlp)
ytmp3 <url>            # Download audio as mp3 (yt-dlp)
```

## Development Servers
```bash
serve                  # Python HTTP server :8000
serve-php              # PHP server :8000
devserver 3000         # Live reload server
```

## Project Management
```bash
newproject myapp python  # Create Python project
newproject webapp go     # Create Go project
prek-init python         # Init pre-commit hooks (prek)
dev                      # cd ~/Developer
cde                      # cd ~/code
```

## Notes & Documentation
```bash
note "meeting notes"   # Quick note taking
note                   # Open today's notes in nvim
cheat git              # Command cheatsheet (cheat.sh)
weather                # Current weather
weather london         # Weather for city
qr "text"              # Generate QR code
```

## SSH & Remote
```bash
ssh-add-keys           # Add SSH keys to agent
ssh-copy-key           # Copy SSH key to clipboard
ssh-tunnel 8080 localhost 80 server # SSH tunnel
```

## macOS Specific
```bash
showfiles              # Show hidden files in Finder
hidefiles              # Hide hidden files in Finder
```

## Dotfiles Sync
```bash
dotsync --all          # Sync all dotfiles
dotsync --dry-run      # Preview changes
dotsync --zsh          # Sync .zsh/ only
dotsync --agentic      # AI agent mode (JSON output)
reload                 # Reload .zshrc
```
