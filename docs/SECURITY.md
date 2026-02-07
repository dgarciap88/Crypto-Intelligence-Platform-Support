# Security Guidelines - Crypto Intelligence Platform

## 🚨 BEFORE PUSHING TO GITHUB

### Critical Security Checks

**NEVER commit these files:**
1. `.env` files with real credentials
2. Any file containing API keys or tokens
3. Database dumps with real data
4. Log files that may contain sensitive info
5. Backup files (*.bak, *.sql, *.dump)

---

## 📋 Pre-Publish Checklist

### 1. Environment Variables

**Files to VERIFY are in .gitignore:**
```
# All projects
.env
.env.*
!.env.example   # Only examples allowed

# Specific paths
Crypto-Intelligence-Platform-Support/.env
Crypto-Intelligence-Platform/.env
Crypto-Intelligence-API/.env
Crypto-Intelligence-Web/.env.local
```

**Sensitive variables that must NEVER be committed:**
- `GITHUB_TOKEN` - Personal access tokens
- `OPENAI_API_KEY` - OpenAI API keys
- `POSTGRES_PASSWORD` - Database passwords
- Any API key, secret, or token

**Action:** Verify `.env.example` files contain only placeholders like:
```bash
GITHUB_TOKEN=your_github_token_here
OPENAI_API_KEY=your_openai_api_key_here
```

### 2. Docker Configuration

**Files to review:**
- `docker-compose.dev.yml` ✅ Safe (uses ${ENV_VAR} syntax)
- `docker-compose.prod.yml` ⚠️ Review before publishing

**Safe pattern:**
```yaml
environment:
  GITHUB_TOKEN: ${GITHUB_TOKEN}  # ✅ Reads from .env
```

**UNSAFE pattern:**
```yaml
environment:
  GITHUB_TOKEN: ghp_xxxxx  # ❌ NEVER hardcode
```

### 3. Code Review

**Search for hardcoded credentials:**
```bash
# Run these searches before publishing
git grep -i "ghp_"           # GitHub tokens
git grep -i "sk-proj-"       # OpenAI keys
git grep -i "sk-"            # OpenAI keys (old format)
git grep -i "password.*="    # Hardcoded passwords
git grep -i "api.*key.*="    # API keys
```

**Safe code patterns:**
```python
# ✅ Good - reads from environment
token = os.getenv("GITHUB_TOKEN")
api_key = os.getenv("OPENAI_API_KEY")

# ❌ Bad - hardcoded
token = "ghp_xxxxx"
api_key = "sk-proj-xxxxx"
```

### 4. Database Files

**Files to exclude:**
- `*.sql` (dumps/backups)
- `*.dump`
- `*.sql.gz`
- `backups/` directory
- `data/` directory with real data

**Exception:** Schema files without data are OK:
- ✅ `db/create_tables.sql` (structure only)
- ❌ `backups/production-dump.sql` (contains data)

### 5. Logs and Debug Files

**Verify these are in .gitignore:**
```
logs/
*.log
__pycache__/
.pytest_cache/
.coverage
*.pyc
node_modules/
dist/
```

### 6. IDE and System Files

**Already in .gitignore, but verify:**
```
.idea/
.DS_Store
*.swp
*.swo
*~
```

---

## 🔍 Pre-Commit Security Scan

Run these commands before `git push`:

```bash
# 1. Check for .env files staged for commit
git status | grep "\.env$"

# 2. Check for sensitive data in staged files
git diff --cached | grep -i "api.*key\|token\|password"

# 3. Verify .gitignore is working
git check-ignore .env
git check-ignore logs/*.log

# 4. List all tracked files (review for sensitive data)
git ls-files | grep -E "\.(env|log|sql|dump)$"
```

**Expected output:** All commands should return empty or confirm files are ignored.

---

## 📁 Safe to Publish

### ✅ These files are SAFE:

**Configuration templates:**
- `.env.example` (with placeholders only)
- `.env.prod.example` (with placeholders only)
- `docker-compose.*.yml` (using ${VAR} syntax)
- `kubernetes/*.yaml` (no secrets)

**Code:**
- All `.py`, `.ts`, `.tsx`, `.js` files (after credential scan)
- `requirements.txt`, `package.json`
- `Dockerfile`, `.dockerignore`

**Documentation:**
- `README.md`
- `docs/*.md`
- `LICENSE`

**Schema files:**
- `db/create_tables.sql` (structure only)
- Migration files without data

---

## 🚫 NEVER Publish

### ❌ These files must NEVER be in repo:

**Credentials:**
- `.env` (real values)
- Any file with API keys, tokens, passwords

**Data:**
- Database dumps with real data
- Backup files
- User data files

**Logs:**
- Application logs
- Debug logs
- Error logs with stack traces containing secrets

**Build artifacts:**
- `node_modules/`
- `dist/`, `build/`
- `__pycache__/`
- `.pytest_cache/`

---

## 🛡️ Security Best Practices

### 1. Use GitHub Secrets for CI/CD

When setting up GitHub Actions:
```yaml
env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

### 2. Rotate Compromised Credentials

If you accidentally commit secrets:
1. **IMMEDIATELY** revoke the compromised token/key
2. Generate new credentials
3. Remove from git history:
   ```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch .env" \
     --prune-empty --tag-name-filter cat -- --all
   ```
4. Force push (⚠️ coordinate with team)
5. Update `.env` locally with new credentials

### 3. Use .env Loading Order

Projects should load environment variables in this priority:
1. System environment variables (highest priority)
2. `.env` file (development only)
3. Defaults in code (lowest priority, non-sensitive only)

### 4. Production Security

For production deployments:
- Use Kubernetes Secrets or similar
- Never use `.env` files in production
- Use cloud provider secret management (AWS Secrets Manager, Azure Key Vault, etc.)
- Enable audit logging

---

## 📝 Incident Response

### If Secrets Are Leaked

1. **Immediate Actions:**
   - Revoke compromised credentials immediately
   - Document what was exposed and when
   - Notify team members

2. **Cleanup:**
   - Remove secrets from git history
   - Update all affected systems
   - Review access logs for unauthorized usage

3. **Prevention:**
   - Add leaked pattern to `.gitignore`
   - Consider pre-commit hooks:
     ```bash
     # Install git-secrets
     git secrets --install
     git secrets --register-aws
     git secrets --add 'ghp_[0-9a-zA-Z]{36}'
     ```

---

## ✅ Final Pre-Publish Command

Run this comprehensive check:

```bash
# Navigate to workspace root
cd /path/to/Crypto-Intelligence-*

# Check for any real secrets
grep -r "ghp_" --exclude-dir=node_modules --exclude-dir=.git .
grep -r "sk-proj-" --exclude-dir=node_modules --exclude-dir=.git .
grep -r "sk-" --exclude-dir=node_modules --exclude-dir=.git --exclude="*.md"

# Verify .env is not tracked
git ls-files | grep "\.env$"

# Check what would be committed
git status
git diff --cached
```

**Only proceed with `git push` if all checks pass.**

---

## 📚 Resources

- [GitHub Security Best Practices](https://docs.github.com/en/code-security/getting-started/securing-your-repository)
- [OWASP Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [git-secrets tool](https://github.com/awslabs/git-secrets)

---

## 🔒 Repository Settings (GitHub)

When publishing, configure:

1. **Enable security features:**
   - Dependency scanning
   - Secret scanning
   - Code scanning (CodeQL)

2. **Branch protection:**
   - Require pull request reviews
   - Require status checks before merging

3. **Add `.github/workflows/security.yml`:**
   ```yaml
   name: Security Scan
   on: [push, pull_request]
   jobs:
     security:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - name: Secret Scan
           run: |
             if git log --all -S "ghp_" | grep -q "ghp_"; then
               echo "⚠️ Found potential GitHub token in history"
               exit 1
             fi
   ```

---

## Contact

For security concerns, contact: [your-security-email@example.com]

**Last Updated:** February 7, 2026
