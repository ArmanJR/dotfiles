# =============================================================================
# Cloud Tools Configuration
# Google Cloud Platform (primary), AWS (secondary)
# =============================================================================

# =============================================================================
# Google Cloud Platform (GCP)
# =============================================================================

# Google Cloud SDK configuration
if [[ -d "$HOMEBREW_PREFIX/Caskroom/google-cloud-sdk" ]]; then
    # Homebrew installation path
    GCP_PATH="$HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    source "$GCP_PATH/path.zsh.inc"
    source "$GCP_PATH/completion.zsh.inc"
elif [[ -d "$HOME/google-cloud-sdk" ]]; then
    # Manual installation path
    GCP_PATH="$HOME/google-cloud-sdk"
    source "$GCP_PATH/path.zsh.inc"
    source "$GCP_PATH/completion.zsh.inc"
fi

# GCloud environment variables
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/application_default_credentials.json"
export CLOUDSDK_PYTHON="python3"

# GCloud aliases
alias gc="gcloud"
alias gce="gcloud compute"
alias gci="gcloud compute instances"
alias gcl="gcloud compute instances list"
alias gcs="gcloud compute ssh"
alias gcz="gcloud config configurations list"
alias gcr="gcloud container"
alias gck="gcloud container clusters"
alias gckl="gcloud container clusters list"
alias gsutil="gsutil"
alias gbq="bq"

# GCloud functions
gcp-project() {
    if [[ -n "$1" ]]; then
        gcloud config set project "$1"
        echo "Switched to project: $1"
    else
        gcloud config get-value project
    fi
}

gcp-auth() {
    gcloud auth login
    gcloud auth application-default login
}

gcp-regions() {
    gcloud compute regions list --format="table(name,status)" --sort-by=name
}

gcp-zones() {
    local region=${1:-us-central1}
    gcloud compute zones list --filter="region:$region" --format="table(name,status)" --sort-by=name
}

# =============================================================================
# Amazon Web Services (AWS)
# =============================================================================

# AWS CLI configuration
if command -v aws >/dev/null 2>&1; then
    # Enable AWS CLI auto-prompt for better UX
    export AWS_CLI_AUTO_PROMPT=on-partial
    
    # AWS completion
    if [[ -f "$HOMEBREW_PREFIX/share/zsh/site-functions/_aws" ]]; then
        source "$HOMEBREW_PREFIX/share/zsh/site-functions/_aws"
    fi
fi

# AWS environment variables
export AWS_DEFAULT_OUTPUT=json
export AWS_PAGER=""

# AWS aliases
alias awsl="aws configure list"
alias awsp="aws configure list-profiles"
alias awsr="aws sts get-caller-identity"
alias ec2="aws ec2"
alias s3="aws s3"
alias iam="aws iam"
alias lambda="aws lambda"
alias ecs="aws ecs"
alias rds="aws rds"

# AWS functions
aws-profile() {
    if [[ -n "$1" ]]; then
        export AWS_PROFILE="$1"
        echo "Switched to AWS profile: $1"
    else
        echo "Current AWS profile: ${AWS_PROFILE:-default}"
    fi
}

aws-regions() {
    aws ec2 describe-regions --output table --query 'Regions[*].[RegionName,OptInStatus]'
}

aws-whoami() {
    aws sts get-caller-identity
}

# =============================================================================
# Multi-Cloud Tools
# =============================================================================

# Terraform configuration
if command -v terraform >/dev/null 2>&1; then
    # Terraform completion
    complete -o nospace -C $(which terraform) terraform
    
    # Terraform environment variables
    export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
    mkdir -p "$TF_PLUGIN_CACHE_DIR"
fi

# Terraform aliases
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfd="terraform destroy"
alias tfv="terraform validate"
alias tff="terraform fmt"
alias tfs="terraform show"
alias tfo="terraform output"

# Terragrunt aliases (if installed)
if command -v terragrunt >/dev/null 2>&1; then
    alias tg="terragrunt"
    alias tgi="terragrunt init"
    alias tgp="terragrunt plan"
    alias tga="terragrunt apply"
    alias tgd="terragrunt destroy"
fi

# Pulumi (Infrastructure as Code alternative)
if command -v pulumi >/dev/null 2>&1; then
    # Pulumi completion
    source <(pulumi gen-completion zsh)
fi

# Pulumi aliases
alias pul="pulumi"
alias pulu="pulumi up"
alias puld="pulumi destroy"
alias pulp="pulumi preview"
alias puls="pulumi stack"

# =============================================================================
# Cloud Development Tools
# =============================================================================

# Skaffold (for Kubernetes development)
if command -v skaffold >/dev/null 2>&1; then
    source <(skaffold completion zsh)
fi

# Helm (Kubernetes package manager)
if command -v helm >/dev/null 2>&1; then
    source <(helm completion zsh)
fi

# Cloud SQL Proxy function
cloud-sql-proxy() {
    local instance="$1"
    local port="${2:-5432}"
    
    if [[ -z "$instance" ]]; then
        echo "Usage: cloud-sql-proxy <instance-connection-name> [port]"
        return 1
    fi
    
    cloud_sql_proxy -instances="$instance"=tcp:$port
}
