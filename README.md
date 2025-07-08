# PhotoTone Editor

An iOS app for AI-powered photo tone matching and editing using SwiftUI and Core ML.

## 🚀 Features

- **Tone Collection**: Browse and manage saved tone styles
- **Create New Tones**: Generate tone styles from reference images
- **Photo Editing**: Apply tones and fine-tune photos with manual adjustments
- **Modern UI**: Beautiful SwiftUI interface with smooth animations
- **Photo Gallery Integration**: Seamless photo picking with PhotosPicker

## 📱 Current Setup

The app is now set up with basic folder structure and core functionality for testing:

### ✅ Completed
- [x] Basic folder structure (Views, ViewModels, Services, Utilities, Extensions)
- [x] Navigation routing between all screens
- [x] Photo gallery selection using PhotosPicker
- [x] MVVM architecture with ViewModels
- [x] Core Image integration for manual adjustments
- [x] Simulated tone transfer effects
- [x] Modern UI with cards and proper styling
- [x] Error handling and loading states

### 🔄 In Progress
- [ ] SwiftData integration for persistence
- [ ] Actual Core ML model integration
- [ ] Advanced tone transfer algorithms
- [ ] Image sharing functionality

## 🏗️ Architecture

```
Tona/
├── App/
│   └── AppDelegate.swift          # App entry point
├── Views/                         # SwiftUI Views
│   ├── HomeView.swift            # Main navigation
│   ├── ToneCollectionView.swift  # Browse saved tones
│   ├── ToneCreationView.swift    # Create new tones
│   ├── PhotoEditorView.swift     # Edit photos
│   └── ManualEditView.swift      # Manual adjustments
├── ViewModels/                    # MVVM ViewModels
│   ├── ToneCollectionViewModel.swift
│   ├── ToneCreationViewModel.swift
│   └── PhotoEditorViewModel.swift
├── Services/                      # Business Logic
│   ├── ToneStyleService.swift    # Core ML integration
│   └── PhotoProcessingService.swift # Image processing
├── Utilities/                     # Helper Classes
│   ├── ImagePickerHelper.swift   # Photo picker utilities
│   └── CoreImageExtensions.swift # Core Image extensions
├── Extensions/                    # Swift Extensions
│   ├── UIImage+Extensions.swift  # Image utilities
│   └── Color+Extensions.swift    # Color theme
└── CoreML/                       # ML Models
    └── (Core ML model to be added) # Placeholder for Core ML model
```

## 🧪 Testing the App

### 1. Navigation Testing
- Launch the app and verify all navigation links work
- Test back navigation and proper title display
- Verify smooth transitions between screens

### 2. Photo Gallery Testing
- Test photo picker in "Create New Tone" screen
- Test photo picker in "Edit Photo" screen
- Verify multiple image selection works
- Test permission handling

### 3. Image Processing Testing
- Test manual adjustments (brightness, contrast, saturation)
- Test tone style buttons in photo editor
- Verify real-time preview updates
- Test save functionality

### 4. UI/UX Testing
- Test on different device sizes
- Verify dark/light mode compatibility
- Test loading states and error handling
- Verify accessibility features

## 🔧 Development Setup

1. Open `Tona.xcodeproj` in Xcode
2. Select your target device/simulator
3. Build and run the project
4. Grant photo library permissions when prompted

## 📋 Next Steps

1. **SwiftData Integration**: Implement persistent storage for tone styles
2. **Core ML Model**: Add actual tone transfer model
3. **Advanced Features**: Add more filter presets and effects
4. **Performance**: Optimize image processing for large photos
5. **Testing**: Add unit tests and UI tests

## 🎨 Design System

The app uses a consistent design system with:
- **Colors**: Blue primary, purple secondary, orange accent
- **Typography**: System fonts with proper hierarchy
- **Spacing**: Consistent 12pt, 16pt, 20pt spacing
- **Shadows**: Subtle shadows for depth
- **Corner Radius**: 8pt for cards, 10pt for buttons

## 📱 Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- Photos library permission

## 🔒 Permissions

The app requires:
- **Photo Library Access**: For selecting and saving images
- **Camera Access**: For taking new photos (future feature)

## 📄 License

This project is for educational and development purposes.
