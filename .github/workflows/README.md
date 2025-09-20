# 🔐 GitHub Actions Setup Guide

This guide will help you configure the repository secrets and environments needed for the complete CI/CD pipeline.

## 📋 Required Repository Secrets

Go to your repository → Settings → Secrets and variables → Actions → Repository secrets

### 🔥 Firebase Configuration

| Secret Name | Description | How to get |
|-------------|-------------|------------|
| `FIREBASE_PROJECT_ID` | Your main Firebase project ID | Firebase Console → Project Settings |
| `FIREBASE_SERVICE_ACCOUNT_PROD` | Service account JSON for production | Firebase Console → Project Settings → Service accounts → Generate new private key |
| `FIREBASE_SERVICE_ACCOUNT_STAGING` | Service account JSON for staging | Create separate staging project or use same with limited permissions |

### 🤖 Google AI Configuration

| Secret Name | Description | How to get |
|-------------|-------------|------------|
| `GEMINI_API_KEY` | Google AI Gemini API key | [Google AI Studio](https://makersuite.google.com/app/apikey) |

### 📱 Mobile App Store Configuration (Optional)

| Secret Name | Description | How to get |
|-------------|-------------|------------|
| `PLAY_STORE_SERVICE_ACCOUNT` | Google Play Console service account JSON | Play Console → Setup → API access → Service accounts |
| `APPLE_ID` | Apple ID for App Store Connect | Your Apple Developer account |
| `APPLE_APP_SPECIFIC_PASSWORD` | App-specific password | Apple ID → Sign-In and Security → App-Specific Passwords |

### 🔔 Notification Configuration (Optional)

| Secret Name | Description | How to get |
|-------------|-------------|------------|
| `SLACK_WEBHOOK_URL` | Slack webhook for notifications | Slack → Apps → Incoming Webhooks |

## 🌍 Environment Configuration

Go to your repository → Settings → Environments

### Create these environments:

1. **staging**
   - Protection rules: None (automatic deployment from develop branch)
   - Environment secrets: Use staging Firebase credentials

2. **production**
   - Protection rules: Required reviewers (recommended)
   - Environment secrets: Use production Firebase credentials

3. **play-store** (if deploying to Google Play)
   - Protection rules: Required reviewers
   - Environment secrets: Play Store credentials

## 🚀 Step-by-Step Setup

### 1. Firebase Setup

```bash
# Create production project
firebase projects:create your-project-id

# Create staging project (recommended)
firebase projects:create your-project-id-staging

# Enable required services for both projects
firebase use your-project-id
firebase firestore:rules --project your-project-id
firebase auth:enable --project your-project-id

firebase use your-project-id-staging
firebase firestore:rules --project your-project-id-staging
firebase auth:enable --project your-project-id-staging
```

### 2. Service Account Creation

For each Firebase project:

1. Go to Firebase Console → Project Settings → Service accounts
2. Click "Generate new private key"
3. Download the JSON file
4. Copy the entire JSON content to the respective secret

### 3. Firebase CLI Token (Alternative)

If you prefer using Firebase CLI token instead of service accounts:

```bash
firebase login:ci
# Copy the token to FIREBASE_TOKEN secret
```

### 4. Google AI Setup

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Add the key to `GEMINI_API_KEY` secret

### 5. Mobile App Store Setup (Optional)

#### Google Play Store:
1. Go to Google Play Console → Setup → API access
2. Create or link a service account
3. Download the JSON key
4. Add to `PLAY_STORE_SERVICE_ACCOUNT` secret

#### Apple App Store:
1. Generate app-specific password from Apple ID settings
2. Add credentials to respective secrets

## 🔧 Workflow Configuration

### Branch Protection Rules

Set up branch protection for `main` and `develop`:

1. Go to Settings → Branches
2. Add protection rules:
   - Require pull request reviews
   - Require status checks to pass
   - Include administrators

### Auto-merge Setup (Optional)

Enable auto-merge for dependabot PRs:

```yaml
# Add to .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "pub"
    directory: "/mobile_app/montanagent"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
    reviewers:
      - "your-username"
    assignees:
      - "your-username"
```

## 📊 Monitoring and Notifications

### Slack Integration

1. Create a Slack app at [api.slack.com](https://api.slack.com/apps)
2. Enable Incoming Webhooks
3. Get webhook URL and add to `SLACK_WEBHOOK_URL` secret

### CodeCov Integration

1. Sign up at [codecov.io](https://codecov.io)
2. Connect your repository
3. No additional secrets needed (uses GitHub token)

## 🔐 Security Best Practices

### Secret Rotation
- Rotate Firebase service account keys every 90 days
- Update API keys if compromised
- Use separate service accounts for production and staging

### Permissions
- Grant minimal required permissions to service accounts
- Use separate Firebase projects for staging and production
- Enable audit logging for sensitive operations

### Environment Protection
- Require manual approval for production deployments
- Limit who can approve production deployments
- Enable deployment protection rules

## 🧪 Testing the Setup

### 1. Test Basic Workflow

Create a small change and push to a feature branch:

```bash
git checkout -b test/workflow-setup
echo "# Test" >> mobile_app/montanagent/README.md
git add .
git commit -m "test: workflow setup"
git push origin test/workflow-setup
```

### 2. Create Pull Request

- Create PR from feature branch to develop
- Check that preview deployment works
- Verify tests run successfully

### 3. Test Staging Deployment

Merge to develop branch and verify staging deployment.

### 4. Test Production Deployment

Merge to main branch and verify production deployment.

## 🐛 Troubleshooting

### Common Issues

#### Firebase Authentication Errors
```
Error: Failed to authenticate with Firebase
```
**Solution**: Check that service account JSON is valid and has correct permissions.

#### Build Failures
```
Error: Flutter build failed
```
**Solution**: Ensure Flutter version matches project requirements.

#### Permission Denied
```
Error: Permission denied to deploy
```
**Solution**: Verify service account has Firebase Hosting Admin role.

### Debug Commands

```bash
# Check workflow status
gh run list

# View specific run logs
gh run view [run-id]

# Check repository secrets (names only)
gh secret list
```

## 📚 Additional Resources

- [Firebase CLI Documentation](https://firebase.google.com/docs/cli)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)

## 🆘 Support

If you encounter issues:

1. Check workflow logs in GitHub Actions tab
2. Verify all secrets are correctly set
3. Ensure Firebase projects are properly configured
4. Check that branch protection rules aren't blocking automated deployments

---

🎉 **Ready to deploy!** Once all secrets are configured, your CI/CD pipeline will automatically handle testing, building, and deploying your MontaNAgent application.