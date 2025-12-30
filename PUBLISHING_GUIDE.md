# VIB34D SDK - Publishing Guide

**How to Publish to pub.dev, npm, and VS Code Marketplace**

---

## ✅ Pre-Publishing Checklist

All required files are now in place:

- ✅ **pubspec.yaml** - Updated with proper metadata, topics, and links
- ✅ **LICENSE** - MIT License added
- ✅ **CHANGELOG.md** - Already exists
- ✅ **README.md** - Already exists
- ✅ **Source code** - All formatted and tested
- ✅ **Documentation** - 10+ comprehensive guides

---

## 📦 Option 1: Publish to pub.dev (Flutter/Dart Package)

### Step 1: Verify Package
```bash
# Test that everything is correct
flutter pub publish --dry-run
```

This will validate:
- Package structure
- File formatting
- Dependencies
- Metadata completeness

### Step 2: Authenticate (First Time Only)
```bash
# Login with your Google account
dart pub login
```

This will:
1. Open browser for Google authentication
2. Grant pub.dev publishing permissions
3. Save credentials locally

### Step 3: Publish
```bash
# Actually publish to pub.dev
flutter pub publish
```

**Confirm when prompted:**
```
Publishing vib34d_xr_quaternion_sdk 1.0.0 to pub.dev:
...
Do you want to publish vib34d_xr_quaternion_sdk 1.0.0 to pub.dev? (y/N)
```

Type `y` and press Enter.

### Step 4: Verify
Visit: https://pub.dev/packages/vib34d_xr_quaternion_sdk

The package should appear within 1-2 minutes.

### Step 5: Update README
Add pub.dev badge to README.md:
```markdown
[![pub package](https://img.shields.io/pub/v/vib34d_xr_quaternion_sdk.svg)](https://pub.dev/packages/vib34d_xr_quaternion_sdk)
```

---

## 🔧 Option 2: Publish CLI to npm

### Step 1: Prepare package.json
```bash
cd cli/vib34d-agent
```

Update `package.json`:
```json
{
  "name": "@vib34d/cli",
  "version": "1.0.0",
  "description": "CLI tool for VIB34D SDK project creation and scaffolding",
  "bin": {
    "vib34d": "./bin/vib34d.js"
  },
  "keywords": [
    "vib34d",
    "4d",
    "visualization",
    "quaternion",
    "flutter",
    "cli",
    "scaffold"
  ],
  "author": "Paul Phillips - Clear Seas Solutions LLC",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/Domusgpt/vib34d-vib3plus.git",
    "directory": "cli/vib34d-agent"
  },
  "homepage": "https://github.com/Domusgpt/vib34d-vib3plus#readme",
  "bugs": "https://github.com/Domusgpt/vib34d-vib3plus/issues",
  "engines": {
    "node": ">=18.0.0"
  }
}
```

### Step 2: Test Package
```bash
# Install dependencies
npm install

# Test locally
npm link
vib34d --version

# Test creation flow
vib34d onboard
```

### Step 3: Login to npm (First Time Only)
```bash
npm login
```

Enter:
- Username
- Password
- Email
- 2FA code (if enabled)

### Step 4: Publish
```bash
# Publish to npm
npm publish --access public
```

**Note**: The `@vib34d` scope requires the `--access public` flag for scoped packages.

### Step 5: Verify
Visit: https://www.npmjs.com/package/@vib34d/cli

Install test:
```bash
npm install -g @vib34d/cli
vib34d --version
```

---

## 🎨 Option 3: Publish VS Code Extension

### Step 1: Install VSCE
```bash
npm install -g @vscode/vsce
```

### Step 2: Prepare Extension
```bash
cd vscode-extension/vib34d-visualizer
npm install
```

### Step 3: Create Personal Access Token

1. Go to: https://dev.azure.com/
2. Sign in with Microsoft account
3. User Settings → Personal Access Tokens
4. Click "New Token"
5. Name: "VS Code Publishing"
6. Organization: All accessible organizations
7. Scopes: Select "Marketplace → Manage"
8. Create token and copy it

### Step 4: Login to Publisher
```bash
vsce login <publisher-name>
# Enter the Personal Access Token when prompted
```

**Publisher name**: Should match `publisher` field in `package.json`

If you don't have a publisher account:
1. Visit: https://marketplace.visualstudio.com/manage
2. Create new publisher
3. Choose a unique ID

### Step 5: Package Extension
```bash
# Create .vsix package
vsce package
```

This creates: `vib34d-visualizer-1.0.0.vsix`

### Step 6: Publish
```bash
# Publish to VS Code Marketplace
vsce publish
```

Or publish manually:
1. Go to: https://marketplace.visualstudio.com/manage
2. Click "New extension"
3. Upload the `.vsix` file

### Step 7: Verify
Visit: https://marketplace.visualstudio.com/items?itemName=<publisher>.vib34d-visualizer

Install test:
```bash
code --install-extension <publisher>.vib34d-visualizer
```

---

## 📊 Post-Publishing Checklist

### After pub.dev Publishing

✅ **Update README.md**
```markdown
## Installation

Add to your `pubspec.yaml`:
```yaml
dependencies:
  vib34d_xr_quaternion_sdk: ^1.0.0
```

Then run:
```bash
flutter pub get
```

✅ **Add Badges**
```markdown
[![pub package](https://img.shields.io/pub/v/vib34d_xr_quaternion_sdk.svg)](https://pub.dev/packages/vib34d_xr_quaternion_sdk)
[![pub points](https://img.shields.io/pub/points/vib34d_xr_quaternion_sdk)](https://pub.dev/packages/vib34d_xr_quaternion_sdk/score)
[![popularity](https://img.shields.io/pub/popularity/vib34d_xr_quaternion_sdk)](https://pub.dev/packages/vib34d_xr_quaternion_sdk/score)
[![likes](https://img.shields.io/pub/likes/vib34d_xr_quaternion_sdk)](https://pub.dev/packages/vib34d_xr_quaternion_sdk/score)
```

✅ **Announce on Social Media**
- Twitter/X: "Just published VIB34D v1.0.0 to pub.dev! 🚀"
- Reddit r/FlutterDev: "VIB34D - 4D Visualization SDK for Flutter"
- Discord: Flutter Community server
- LinkedIn: Professional announcement

✅ **Submit to Directories**
- Hacker News: "Show HN: VIB34D - 4D visualization toolkit for Flutter"
- Product Hunt: Create product page
- Dev.to: Write announcement article

---

### After npm Publishing

✅ **Update CLI README**
```markdown
## Installation

Install globally:
```bash
npm install -g @vib34d/cli
```

Verify installation:
```bash
vib34d --version
```

✅ **Add npm Badge**
```markdown
[![npm version](https://img.shields.io/npm/v/@vib34d/cli.svg)](https://www.npmjs.com/package/@vib34d/cli)
[![npm downloads](https://img.shields.io/npm/dm/@vib34d/cli.svg)](https://www.npmjs.com/package/@vib34d/cli)
```

---

### After VS Code Marketplace Publishing

✅ **Update Extension README**
```markdown
## Installation

1. Open VS Code
2. Press Ctrl+P (Cmd+P on Mac)
3. Type: `ext install <publisher>.vib34d-visualizer`
4. Press Enter

Or search "VIB34D" in Extensions marketplace.
```

✅ **Add Marketplace Badge**
```markdown
[![VS Code Marketplace](https://img.shields.io/visual-studio-marketplace/v/<publisher>.vib34d-visualizer.svg)](https://marketplace.visualstudio.com/items?itemName=<publisher>.vib34d-visualizer)
[![Installs](https://img.shields.io/visual-studio-marketplace/i/<publisher>.vib34d-visualizer.svg)](https://marketplace.visualstudio.com/items?itemName=<publisher>.vib34d-visualizer)
```

---

## 🚀 Marketing After Publishing

### Immediate (Day 1)

**Social Media Announcement**:
```
🚀 VIB34D v1.0.0 is now live!

The most powerful 4D visualization toolkit for Flutter:
✅ Quaternion-based rotations
✅ 5 input methods (mouse, touch, keyboard, gamepad, motion)
✅ Web, mobile, desktop support
✅ AI-powered development tools

Get started: flutter pub add vib34d_xr_quaternion_sdk

#Flutter #4D #Visualization #OpenSource
```

**Show HN Post**:
```
Title: VIB34D – 4D visualization toolkit for Flutter

Hey HN! I built VIB34D, a Flutter SDK for creating 4D geometric visualizations with quaternion-based rotations.

Key features:
- 5 input methods (mouse, touch, keyboard, gamepad, device motion)
- Works on web, mobile, and desktop
- AI-powered dev tools (Claude Code, MCP, CLI, VS Code extension)
- Complete documentation and examples

Live demo: [link]
GitHub: https://github.com/Domusgpt/vib34d-vib3plus
pub.dev: https://pub.dev/packages/vib34d_xr_quaternion_sdk

Would love your feedback!
```

**Reddit r/FlutterDev**:
```
Title: [Package Release] VIB34D - 4D Visualization SDK with Quaternion Rotations

Hey r/FlutterDev! Just published VIB34D v1.0.0 to pub.dev.

It's a comprehensive SDK for creating 4D geometric visualizations with support for:
- Multiple input methods
- Cross-platform (web/mobile/desktop)
- AI-powered development
- 10+ guides and examples

Would love to hear what you think!

pub.dev: [link]
Demo: [link]
```

---

### Week 1-2

**Content Marketing**:
1. Write blog post: "Building 4D Visualizations in Flutter with VIB34D"
2. Create video tutorial: "Get started with VIB34D in 5 minutes"
3. Post to Dev.to with tutorial
4. Create Twitter thread with GIFs/videos
5. Submit to Flutter Awesome

**Community Engagement**:
1. Answer questions on StackOverflow (tag: flutter, 4d, quaternion)
2. Engage with comments on Reddit/HN
3. Create Discord server for community
4. Reach out to Flutter newsletters

---

### Month 1

**Advanced Content**:
1. Case study: "How Company X built Y with VIB34D"
2. Comparison article: "VIB34D vs Three.js vs Unity for 4D viz"
3. Technical deep dive: "Understanding Quaternions with VIB34D"
4. Video series: Advanced tutorials

**Partnerships**:
1. Reach out to Flutter influencers
2. Contact Flutter podcast hosts
3. Submit talk proposals to Flutter conferences
4. Reach out to companies using similar tech

---

## 📈 Tracking Success

### Key Metrics to Monitor

**pub.dev**:
- Downloads (daily/weekly/monthly)
- Pub points (aim for 130+)
- Popularity score
- Likes
- Issues reported

**npm**:
- Downloads (daily/weekly)
- Stars on npm
- Usage in projects

**VS Code Marketplace**:
- Installs
- Ratings
- Reviews

**GitHub**:
- Stars
- Forks
- Issues
- PRs
- Contributors

**Community**:
- Discord members
- Gallery submissions
- StackOverflow questions
- Social media mentions

---

## 🎯 Success Targets

### First Week
- ✅ 100+ pub.dev downloads
- ✅ 50+ GitHub stars
- ✅ 10+ social media shares

### First Month
- ✅ 1,000+ pub.dev downloads
- ✅ 200+ GitHub stars
- ✅ 50+ Discord members
- ✅ 5+ gallery submissions

### First Quarter
- ✅ 10,000+ pub.dev downloads
- ✅ 1,000+ GitHub stars
- ✅ 500+ Discord members
- ✅ 100+ gallery submissions

---

## 🔄 Version Updates

### When to Publish Updates

**Patch (1.0.X)**: Bug fixes only
```bash
# Update version in pubspec.yaml to 1.0.1
flutter pub publish
```

**Minor (1.X.0)**: New features, backwards compatible
```bash
# Update version in pubspec.yaml to 1.1.0
flutter pub publish
```

**Major (X.0.0)**: Breaking changes
```bash
# Update version in pubspec.yaml to 2.0.0
# Add migration guide
flutter pub publish
```

**Always update CHANGELOG.md before publishing!**

---

## ⚠️ Common Publishing Issues

### Issue: "Package has errors"
**Solution**: Run `flutter pub publish --dry-run` to see specific errors

### Issue: "Authentication failed"
**Solution**: Run `dart pub login` again

### Issue: "Package name already taken"
**Solution**: Choose different name in pubspec.yaml

### Issue: "Score is low on pub.dev"
**Solution**:
- Add more documentation
- Improve example code
- Add tests
- Follow Flutter best practices
- Update to latest dependencies

### Issue: "VS Code extension not showing"
**Solution**:
- Check publisher account is verified
- Ensure categories are set correctly
- Wait 5-10 minutes for indexing

---

## 📞 Need Help?

**pub.dev Issues**: https://github.com/dart-lang/pub-dev/issues
**npm Issues**: https://docs.npmjs.com/support
**VS Code Issues**: https://code.visualstudio.com/docs/editor/extension-marketplace

---

## ✅ Ready to Publish!

All files are prepared and the package is ready to go. Follow the steps above to publish to:

1. ✅ pub.dev (Flutter/Dart developers)
2. ✅ npm (CLI tool)
3. ✅ VS Code Marketplace (extension)

**Estimated total time**: 1-2 hours for all three

Good luck with the launch! 🚀

---

**Next Steps After Publishing**: See PRODUCT_ENHANCEMENT_STRATEGY.md for growth strategies.
