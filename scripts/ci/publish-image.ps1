param(
    [switch]$WhatIf
)

# Publish image helper script (PowerShell)
# - Stages changes, commits, pushes, and triggers GitHub Actions workflow_dispatch
# - Requires environment variable: GITHUB_TOKEN (personal access token or repo-scoped token)

function Write-ErrAndExit($msg) {
    Write-Host "ERROR: $msg" -ForegroundColor Red
    exit 1
}

if (-not $env:GITHUB_TOKEN) {
    Write-ErrAndExit "Environment variable GITHUB_TOKEN is not set. Please set it before running this script. Example: `$env:GITHUB_TOKEN = 'ghp_...yourtoken...'`"
}

$repoOwner = 'jandromani'
$repoName = 'TESTCOPILOT'
$workflowFile = 'build-and-push-image.yml'
$branch = 'master'

Write-Host "Staging changes..."
git add -A

$status = git status --porcelain
if (-not $status) {
    Write-Host "No changes to commit. Proceeding to trigger workflow..."
} else {
    Write-Host "Committing changes..."
    git commit -m "chore(ci): add publish scripts and remote run docs" || Write-ErrAndExit "git commit failed"
}

Write-Host "Pushing to origin/$branch..."
if ($WhatIf) { Write-Host "WhatIf: would run git push origin $branch"; exit 0 }

# Attempt push (may prompt for credentials if not using token/ssh)
git push origin $branch
if ($LASTEXITCODE -ne 0) {
    Write-ErrAndExit "git push failed. Ensure you have push access and credentials configured (SSH key or PAT)."
}

Write-Host "Triggering GitHub Actions workflow_dispatch for $workflowFile on $branch..."

$url = "https://api.github.com/repos/$repoOwner/$repoName/actions/workflows/$workflowFile/dispatches"
$body = @{ ref = $branch } | ConvertTo-Json

try {
    $resp = Invoke-RestMethod -Uri $url -Method Post -Headers @{ Authorization = "token $env:GITHUB_TOKEN"; "User-Agent" = "publish-image-script" } -Body $body -ContentType "application/json"
    Write-Host "Workflow dispatched successfully. Check Actions tab in GitHub." -ForegroundColor Green
} catch {
    Write-ErrAndExit "Failed to dispatch workflow: $($_.Exception.Message)"
}
