# Tona - AI-Powered Photo Tone Editor

<p align="center">
  <img src="Resources/AppIcon.png" width="200" alt="Tona App Icon">
</p>

Tona is an iOS app that uses AI to apply custom tone filters to your photos. Create unique tone presets from reference images and apply them to your photos with professional-quality results.

## Features

- 🎨 **Custom Tone Creation**: Upload reference images to generate unique tone presets
- 📸 **Smart Photo Editing**: Apply AI-generated tones to your photos
- 🎛️ **Fine-tune Controls**: Adjust contrast, brightness, and other parameters
- 💾 **Tone Library**: Save and organize your favorite tone presets
- 📤 **Easy Sharing**: Export edited photos to your camera roll or share directly

## Screenshots

<p align="center">
  <img src="Resources/Screenshots/tone-gallery.png" width="250" alt="Tone Gallery">
  <img src="Resources/Screenshots/upload-photo.png" width="250" alt="Upload Photo">
  <img src="Resources/Screenshots/adjust-screen.png" width="250" alt="Adjust Screen">
</p>

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Ruby (for Fastlane)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/Apple_Tona.git
cd Apple_Tona
```

### 2. Install Dependencies

#### Ruby Dependencies (Fastlane)

```bash
bundle install --path vendor/bundle
```

### 3. Environment Configuration

1. Copy the environment template:
   ```bash
   cp .env.template .env
   ```

2. Edit `.env` and add your configuration:
   ```bash
   # API Configuration
   API_BASE_URL=https://your-api-endpoint.com
   API_KEY=your_api_key_here
   
   # Apple Developer Account
   FASTLANE_APPLE_ID=your_apple_id@example.com
   FASTLANE_TEAM_ID=your_team_id
   ```

### 4. Open in Xcode

```bash
open Tona.xcodeproj
```

### 5. Configure Code Signing

1. Select the project in Xcode
2. Go to "Signing & Capabilities" tab
3. Select your development team
4. Ensure automatic signing is enabled for development

## Building & Running

### Development Build

1. Select your target device or simulator in Xcode
2. Press `Cmd + R` to build and run

### Using Fastlane

```bash
# Run tests
bundle exec fastlane test

# Build without uploading
bundle exec fastlane build

# Build and upload to TestFlight
bundle exec fastlane beta

# Create screenshots
bundle exec fastlane screenshots

# Release to App Store
bundle exec fastlane release
```

## Project Structure

```
Apple_Tona/
├── tona/                    # Main app source code
│   ├── Models/             # Data models
│   ├── Views/              # SwiftUI views
│   ├── ViewModels/         # View models
│   ├── Services/           # API and business logic
│   └── Resources/          # Assets and resources
├── TonaTests/              # Unit tests
├── TonaUITests/            # UI tests
├── fastlane/               # Fastlane configuration
│   ├── Fastfile           # Lane definitions
│   └── Appfile            # App configuration
└── Resources/              # App resources and screenshots
```

## Navigation Flow

### Main Screens

1. **Splash Screen**
   - Shows app logo/animation
   - Navigates to Tone Gallery

2. **Tone Gallery**
   - Main entry point with tone presets
   - Add new tones or select existing ones

3. **Upload Preference**
   - Upload reference images for new tones
   - AI generates custom tone preset

4. **Tone Result**
   - Preview generated tone
   - Save to library or apply to photos

5. **Upload Photo**
   - Select photos to edit
   - Apply tone presets

6. **Adjust Screen**
   - Fine-tune photo adjustments
   - Real-time preview

## API Integration

The app connects to a backend API for AI tone generation. Configure your API endpoint and authentication in the `.env` file.

### API Endpoints Required:

- `POST /api/tones/generate` - Generate tone from reference images
- `GET /api/tones` - Fetch user's tone library
- `POST /api/photos/apply-tone` - Apply tone to photo

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint for code consistency
- Write unit tests for new features
- Update documentation as needed

## Troubleshooting

### Common Issues

1. **Build fails with signing error**
   - Ensure you have a valid development team selected
   - Check that your Apple ID is properly configured

2. **Fastlane authentication issues**
   - Create an app-specific password for 2FA accounts
   - Set `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` in `.env`

3. **API connection errors**
   - Verify API_BASE_URL in `.env` is correct
   - Check network connectivity
   - Ensure API_KEY is valid

## License

This project is proprietary software. All rights reserved.

## Contact

For questions or support, please contact: [your-email@example.com]

---

*Built with ❤️ using SwiftUI and AI*
