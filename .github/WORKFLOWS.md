# 🚀 GitHub Actions Workflows Quick Reference

## 📋 Workflow Overview

| Workflow | Trigger | Purpose | Duration |
|----------|---------|---------|----------|
| **CI/CD Pipeline** | Push to main/develop, PRs | Complete testing, building, and deployment | ~15-20 min |
| **Testing Suite** | Push, PRs, Daily 2 AM UTC | Comprehensive testing across multiple suites | ~10-15 min |
| **Deployment** | Push to main/develop, Manual | Environment-specific deployments | ~8-12 min |
| **Release Management** | Tags, Manual | Version management and releases | ~20-25 min |
| **Staging & Preview** | PRs, Push to develop/feature | Preview deployments and staging | ~5-10 min |

## 🎯 Trigger Quick Reference

### Automatic Triggers
```
main branch push          → Production deployment
develop branch push       → Staging deployment
feature/* branch push     → Preview deployment
Pull request opened       → Preview + tests
Tag push (v*.*.*)        → Release workflow
Daily at 2 AM UTC        → Full test suite
```

### Manual Triggers
```
Deployment workflow       → Choose environment (staging/production)
Release workflow         → Version bump (patch/minor/major)
Staging workflow         → Deploy specific branch
```

## 🌍 Environment Flow

```
Feature Branch → PR Preview → Develop (Staging) → Main (Production)
     ↓              ↓            ↓                    ↓
   Tests          Tests +      Staging            Production
                 Preview      Deployment          Deployment
```

## 📦 Build Artifacts

| Platform | Artifact | Retention | Usage |
|----------|----------|-----------|-------|
| Web | `web-build` | 30 days | Firebase Hosting |
| Android APK | `android-apk` | 30 days | Direct download |
| Android Bundle | `android-bundle` | 30 days | Play Store |
| Coverage | `coverage-report` | 7 days | CodeCov integration |
| Screenshots | `preview-screenshot` | 7 days | Visual testing |

## 🔐 Required Secrets

### Essential (Required for basic functionality)
- `FIREBASE_PROJECT_ID`
- `FIREBASE_SERVICE_ACCOUNT_PROD`
- `FIREBASE_SERVICE_ACCOUNT_STAGING`
- `GEMINI_API_KEY`

### Optional (Enhanced functionality)
- `SLACK_WEBHOOK_URL`
- `PLAY_STORE_SERVICE_ACCOUNT`
- `APPLE_ID` / `APPLE_APP_SPECIFIC_PASSWORD`

## 🧪 Test Categories

| Test Type | Location | Purpose | Coverage |
|-----------|----------|---------|----------|
| Unit | `test/unit/` | Business logic | Services, utilities |
| Widget | `test/widget/` | UI components | Screens, widgets |
| Integration | `integration_test/` | End-to-end | User flows |
| Performance | `test/performance/` | Speed & efficiency | Load times, memory |

## 📊 Status Badges

Add these to your README.md:

```markdown
![CI/CD](https://github.com/your-org/fam/workflows/CI%2FCD%20Pipeline/badge.svg)
![Tests](https://github.com/your-org/fam/workflows/Comprehensive%20Testing/badge.svg)
![Deployment](https://github.com/your-org/fam/workflows/Deployment%20Pipeline/badge.svg)
```

## 🚀 Quick Actions

### Deploy to Production
```bash
git checkout main
git merge develop
git push origin main
# Automatic production deployment triggered
```

### Create Release
```bash
git tag v1.2.3
git push origin v1.2.3
# Automatic release workflow triggered
```

### Manual Deploy
1. Go to Actions tab
2. Select "Deployment Pipeline"
3. Click "Run workflow"
4. Choose environment

### Emergency Rollback
1. Go to Actions tab
2. Find last successful production deployment
3. Re-run the deployment job
4. Or use Firebase Console to rollback hosting

## 🔍 Debugging Workflows

### Check Status
```bash
# Install GitHub CLI
gh run list --workflow="CI/CD Pipeline"
gh run view [run-id] --log
```

### Common Fixes
- **Build fails**: Check Flutter version in workflow
- **Deploy fails**: Verify Firebase service account permissions
- **Tests fail**: Check test dependencies and environment
- **Secrets error**: Verify all required secrets are set

## 📈 Performance Expectations

### Build Times (Typical)
- **Web build**: 3-5 minutes
- **Android build**: 5-8 minutes
- **Tests**: 2-4 minutes
- **Deploy**: 1-2 minutes

### Resource Usage
- **Concurrent jobs**: Up to 6 (GitHub free tier: 20)
- **Monthly minutes**: ~200-300 minutes per release cycle
- **Storage**: ~500MB artifacts per month

## 🎛️ Customization Points

### Modify Flutter Version
Edit in workflow files:
```yaml
env:
  FLUTTER_VERSION: '3.35.4'  # Update this
```

### Add New Environments
1. Create environment in GitHub Settings
2. Add to deployment workflow
3. Configure Firebase project

### Custom Test Commands
Edit in `testing.yml`:
```yaml
- name: 🧪 Run custom tests
  run: flutter test --custom-flag
```

## 🔄 Workflow Dependencies

```
CI/CD Pipeline
├── Testing Suite
├── Security Scanning
└── Deployment Pipeline
    ├── Staging & Preview
    └── Release Management
```

---

💡 **Pro Tip**: Use GitHub's "Re-run failed jobs" feature to save time when only specific jobs fail.

🔗 **Links**: [Actions Tab](../../actions) | [Settings](../../settings) | [Environments](../../settings/environments)