# 🔒 SECURITY INCIDENT - API KEY EXPOSED

**Status:** ⚠️ CRITICAL - Immediate action required  
**Date:** December 3, 2025  
**Issue:** OPENROUTER_API_KEY hardcoded in `.env` and `.env.example` and exposed in git history

---

## What Happened

Your OpenRouter API key was **hardcoded directly in `.env` and `.env.example`** and committed to the Git repository. GitHub's automated scanning detected the exposed secret and:

1. Notified you (correos de OpenRouter)
2. Likely flagged the key to OpenRouter
3. OpenRouter **revoked the key** (invalidated it)

This is why your key no longer works.

---

## Immediate Actions (DO NOW)

### 1. Generate a NEW API Key
- Go to: https://openrouter.ai
- Sign in to your account
- Navigate to: API Keys / Settings / Keys
- Click "Generate New Key" (this creates a fresh key)
- Copy the new key: `sk-or-v1-...`
- (Optional) Delete the old compromised key

### 2. Clean Git History (Remove Exposed Key)

The key is still in your Git history. Remove it completely:

```powershell
# Option A: Using BFG Repo-Cleaner (easiest)
# Download from: https://rtyley.github.io/bfg-repo-cleaner/
# Then run:
bfg --delete-files .env
bfg --replace-text passwords.txt  # if you have a list
git reflog expire --expire=now --all && git gc --prune=now --aggressive

# Option B: Using git filter-branch (native git)
git filter-branch --tree-filter 'rm -f .env .env.example' HEAD
git push --force-with-lease

# Option C: If repo is small/fresh, just delete and recommit:
# (Not recommended for production, but fastest for new repos)
```

### 3. Update `.env` Files (DONE ✅)
- `.env` now has empty `OPENROUTER_API_KEY=`
- `.env.example` now has placeholder `OPENROUTER_API_KEY=sk-or-v1-YOUR-KEY-HERE`

### 4. Add GitHub Secret (For CI/CD)
- Go to GitHub → Settings → Secrets and variables → Actions
- Click "New repository secret"
- Name: `OPENROUTER_API_KEY`
- Value: Your **NEW** key (generated in step 1)

### 5. Update Local `.env`
In your local machine:

```powershell
# Edit .env locally (never commit it):
# OPENROUTER_API_KEY=sk-or-v1-YOUR-NEW-KEY-HERE
```

### 6. Verify `.gitignore` (Already OK ✅)
Confirm `.env` is ignored:
```bash
cat .gitignore | grep "\.env"
# Should show: .env
```

---

## Prevention Going Forward

### ✅ DO:
- Never commit `.env` or secrets to Git
- Use `.env.example` as a template (placeholder values only)
- Use GitHub Secrets for CI/CD (GitHub Actions will inject from `${{ secrets.NAME }}`)
- Rotate keys regularly
- Use different keys for dev/staging/prod

### ❌ DON'T:
- Hardcode API keys in code
- Commit `.env` files
- Share keys in Slack, email, or public channels
- Reuse the same key across environments
- Commit passwords or secrets to Git

---

## Files Changed (Cleaned)

| File | Change | Status |
|------|--------|--------|
| `.env` | Removed hardcoded key | ✅ |
| `.env.example` | Set placeholder | ✅ |
| `.github/workflows/run-pipeline.yml` | Uses `${{ secrets.OPENROUTER_API_KEY }}` | ✅ |
| `.gitignore` | `.env` already ignored | ✅ |

---

## Verify It Works

After adding the new key to GitHub Secrets:

1. Push changes:
   ```powershell
   git add .env .env.example .gitignore
   git commit -m "chore: secure API keys (remove hardcoded secrets)"
   git push origin main
   ```

2. Test workflow:
   - Go to GitHub → Actions → "Run Pipeline CI"
   - Click "Run workflow" (main branch)
   - The workflow will use the secret from GitHub (not from repo files)

3. Or test locally:
   ```powershell
   $env:OPENROUTER_API_KEY = "sk-or-v1-YOUR-NEW-KEY"
   node scripts/test-openrouter-direct.js
   ```

---

## Resources

- GitHub Secrets: https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions
- BFG Repo-Cleaner: https://rtyley.github.io/bfg-repo-cleaner/
- OpenRouter Security: https://openrouter.ai/docs/security
- OWASP API Keys: https://owasp.org/www-community/API_key

---

## Next Steps

1. ✅ Cleaned `.env` and `.env.example` (already done)
2. 👉 Generate new API key at https://openrouter.ai
3. 👉 Add new key to GitHub Secrets
4. 👉 Push cleaned code to repo
5. 👉 Run workflow to verify it works

**Your system is secure once you:**
- ✅ Generate a new key (OpenRouter)
- ✅ Add to GitHub Secrets
- ✅ Push cleaned repo code

---

_Security is not optional. Your API key is like a credit card number. Treat it as such._ 🔐
