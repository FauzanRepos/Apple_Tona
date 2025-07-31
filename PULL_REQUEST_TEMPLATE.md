# Add Fastlane CI/CD and Update Documentation

## Summary

This PR adds Fastlane configuration for automated builds and TestFlight deployment, along with comprehensive documentation updates.

## Changes Made

### 1. Fastlane Setup
- ✅ Added `Gemfile` with Fastlane dependency
- ✅ Created `fastlane/Fastfile` with lanes for:
  - `beta` - Build and upload to TestFlight with automatic version bumping
  - `build` - Build IPA without uploading
  - `test` - Run unit tests
  - `screenshots` - Generate app screenshots
  - `release` - Full App Store release workflow
- ✅ Created `fastlane/Appfile` with bundle identifier configuration

### 2. Documentation Updates
- ✅ Completely rewrote `README.md` with:
  - Project overview and features
  - Setup instructions
  - Environment configuration guide
  - Build and deployment instructions
  - Project structure documentation
  - Troubleshooting section

### 3. Environment Configuration
- ✅ Added `.env.template` file with all required environment variables
- ✅ Updated `.gitignore` to exclude:
  - `.env` files
  - `vendor/` directory (Ruby gems)
  - `build/` directory
  - `Gemfile.lock`

## Testing Instructions

1. Clone the branch and install dependencies:
   ```bash
   bundle install --path vendor/bundle
   ```

2. Copy and configure environment:
   ```bash
   cp .env.template .env
   # Edit .env with your credentials
   ```

3. Test Fastlane lanes:
   ```bash
   # Run tests
   bundle exec fastlane test
   
   # Build without uploading
   bundle exec fastlane build
   ```

## Deployment Instructions

To deploy to TestFlight:
```bash
bundle exec fastlane beta
```

This will:
- Increment build number
- Build the app
- Upload to TestFlight
- Commit version changes
- Tag the release

## Checklist

- [x] Fastlane configuration added
- [x] README updated with comprehensive documentation
- [x] Environment template created
- [x] .gitignore updated
- [x] All changes tested locally
- [ ] Code review requested
- [ ] Merge to main branch

## Notes

- The `beta` lane automatically increments build numbers and creates git tags
- Ensure you have valid Apple Developer credentials before running deployment lanes
- API configuration is required in `.env` file for the app to function properly

## Screenshots

The README now includes placeholders for app screenshots. Please add actual screenshots to `Resources/Screenshots/` before merging:
- `tone-gallery.png`
- `upload-photo.png`
- `adjust-screen.png`
