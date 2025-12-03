# Run the WorldMiniApp container remotely

This guide explains how to publish the Docker image to GitHub Container Registry (GHCR) and run it on a remote host (Linux VM / droplet / cloud VM).

## 1) Publish image from GitHub Actions

1. Push this branch to GitHub (if not already pushed).
2. In GitHub, go to `Actions` → `Build and Publish Docker Image` → `Run workflow`.
3. Wait until the job completes. The workflow will push `ghcr.io/<OWNER>/<REPO>:latest`.

Notes:
- The workflow uses `GITHUB_TOKEN` to push to GHCR. If push fails due to permissions, create a Personal Access Token with `write:packages` and add it to `Settings → Secrets` as `GHCR_PAT`, then modify the login step to use that secret.

## 2) Pull & run on a remote Linux host

On your remote host (Ubuntu example):

```bash
# Install Docker (Ubuntu)
sudo apt update; sudo apt install -y docker.io
sudo systemctl enable --now docker
# Optionally add your user to docker group
sudo usermod -aG docker $USER
# Re-login or run with sudo

# Pull the image
docker pull ghcr.io/<OWNER>/<REPO>:latest

# Run the container (example)
# Replace <YOUR_KEY> with the new OpenRouter key (DO NOT commit this anywhere)
docker run --rm \
  -e OPENROUTER_API_KEY="sk-or-v1-YOUR-NEW-KEY" \
  -e ENABLE_LLM=1 \
  -v $(pwd)/state:/usr/src/app/state \
  ghcr.io/<OWNER>/<REPO>:latest

# The container's default CMD runs the pipeline against tests/fixtures/example-spec.json.
# To run an interactive shell inside the image for debugging:

docker run --rm -it \
  -e OPENROUTER_API_KEY="sk-or-v1-YOUR-NEW-KEY" \
  -v $(pwd)/state:/usr/src/app/state \
  ghcr.io/<OWNER>/<REPO>:latest /bin/bash

# Inside the container, you can run:
# node scripts/test-openrouter-direct.js
# or
# node scripts/run-all-agents.js tests/fixtures/example-spec.json
```

## 3) Windows / PowerShell example

```powershell
# Pull the image
docker pull ghcr.io/<OWNER>/<REPO>:latest

# Run the container
docker run --rm -e OPENROUTER_API_KEY="sk-or-v1-YOUR-NEW-KEY" -e ENABLE_LLM=1 -v ${PWD}\state:/usr/src/app/state ghcr.io/<OWNER>/<REPO>:latest
```

## 4) Verify connectivity from inside the container

1. Run the container in interactive mode:

```bash
docker run --rm -it -e OPENROUTER_API_KEY="sk-or-v1-YOUR-NEW-KEY" ghcr.io/<OWNER>/<REPO>:latest /bin/bash
```

2. Inside the container:

```bash
node scripts/test-openrouter-direct.js
# or test network level
nslookup api.openrouter.ai
curl -v https://api.openrouter.ai
```

If DNS resolution and HTTPS succeed from the remote host, the LLM will work when you run the pipeline there.

## 5) Optional: Run on a cloud VM automatically

I can provide a small script to spin up a droplet/VM and run the container. Tell me which provider you prefer (DigitalOcean, AWS, or other) and I'll add it.
