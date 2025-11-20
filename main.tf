terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  token = "ghp_K0uPa0oAcs4Cy95qMaoEUXc0pZMSev0h92uv"
  owner = "nazariybu"
}

# === Repository ===
resource "github_repository" "repo" {
  name           = "github-terraform-task-nazariybu"
  visibility     = "private"
}

# === Create develop branch ===
resource "github_branch" "develop_branch" {
  repository     = github_repository.repo.name
  branch         = "develop"
}

# === Set develop branch as default ===
resource "github_branch_default" "develop_default_branch"{
  repository     = github_repository.repo.name
  branch         = "develop"
}

# resource "github_repository_file" "develop_readme" {
#  repository     = github_repository.repo.name
#  branch         = "develop"
#  file           = "README.md"
#  content        = "Develop branch initialized"
#  commit_message = "init develop"
#}

# === Branch protection: main ===
resource "github_branch_protection" "main_protect_rules" {
  repository_id = github_repository.repo.name
  pattern     = "main"

  required_pull_request_reviews {
    require_code_owner_reviews      = true
    required_approving_review_count = 0
  }
}

# === Branch protection: develop ===
resource "github_branch_protection" "develop_protect_rules" {
  repository_id = github_repository.repo.name
  pattern     = "develop"

  required_pull_request_reviews {
    require_code_owner_reviews      = true
    required_approving_review_count = 2
  }
}

# === Collaborator softservedata ===
resource "github_repository_collaborator" "collab" {
  repository = github_repository.repo.name
  username   = "softservedata"
  permission = "push"
}

# === CODEOWNERS ===
resource "github_repository_file" "codeowners" {
  repository          = github_repository.repo.name
  branch              = "main"
  file                = ".github/CODEOWNERS"
  content             = "* @softservedata"
  overwrite_on_create = true
}

# === Main PR Template ===
resource "github_repository_file" "main_pr_template" {
  repository = github_repository.repo.name
  branch     = "main"
  file       = ".github/pull_request_template.md"
  content    = <<EOF
## Describe your changes

## Issue ticket number and link

## Checklist
- [ ] self-review
- [ ] tests added if core feature
- [ ] analytics?
- [ ] product update summary
EOF
  overwrite_on_create = true
}

# === Develop PR Template ===
resource "github_repository_file" "develop_pr_template" {
  repository = github_repository.repo.name
  branch     = "develop"
  file       = ".github/pull_request_template.md"
  content    = <<EOF
## Describe your changes

## Issue ticket number and link

## Checklist
- [ ] self-review
- [ ] tests added if core feature
- [ ] analytics?
- [ ] product update summary
EOF
  overwrite_on_create = true
  depends_on          = [github_branch.develop_branch]
}

# === Discord webhook for PR notifications ===
resource "github_repository_webhook" "discord" {
  repository = github_repository.repo.name

  configuration {
    url          = "https://discord.com/api/webhooks/1434528298469425152/ahq_77FaqV3yRJAgCgwsYRgYUpfUbY1lkennHXuH60o7EIRUaYB6bfefJK_A3WSP"
    content_type = "application/json"
  }

  events         = ["pull_request"]
}

# === Deploy key ===
resource "github_repository_deploy_key" "repositroy_deploy_key" {
  repository = github_repository.repo.name
  title      = "DEPLOY_KEY"
  key        = "ssh-rsa b3BlbnNzaC1rZ"
  read_only  = false
}

# === Save PAT token to GitHub Actions secret ===
resource "github_actions_secret" "pat" {
  repository      = github_repository.repo.name
  secret_name     = "PAT"
  plaintext_value = "ghp_px7GLoGAEoGbblKAJOeakShgPvQzN04aaaa"
}
