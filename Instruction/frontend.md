# Tona iOS Frontend Implementation Guide

## Project Overview

Tona is a mobile photo processing application that uses AI to process and enhance images. Based on the design system and API structure, this document outlines the implementation approach for the iOS app.

## Design System Implementation

### Color Palette
- **Primary Blue:** #007AFF (CTA buttons and active states)
- **Primary Dark Blue:** #1E3A5F
- **Light Gray:** #F5F5F5 (backgrounds)
- **Medium Gray:** #D1D1D6 (borders and secondary text)
- **Dark Gray:** #8E8E93
- **White:** #FFFFFF
- **Success:** #34C759
- **Warning:** #FF9500
- **Error:** #FF3B30

### Typography (SF Pro)
- **Title1:** 28px, bold, 34px line height (main screen titles)
- **Title2:** 22px, bold, 28px line height (section headers)
- **Body:** 17px, regular, 22px line height (primary body text)
- **Caption:** 15px, regular, 20px line height (secondary descriptions)
- **ButtonText:** 17px, semibold (button labels)

### Spacing System (8px base unit)
- **xs:** 4px
- **sm:** 8px
- **md:** 16px
- **lg:** 24px
- **xl:** 32px
- **xxl:** 48px
- **Screen Margins:** 20px
- **Card Padding:** 16px
- **Button Padding:** 12px 24px

### Border Radius
- **Small:** 8px
- **Medium:** 12px (cards, buttons, images)
- **Large:** 16px (containers)
- **Circular:** 50%

### Shadows
- **Light:** 0 2px 8px rgba(0, 0, 0, 0.1) (cards, modals)
- **Medium:** 0 4px 16px rgba(0, 0, 0, 0.15) (floating elements)

## Technology Stack

### Core Technologies
- **SwiftUI** - Modern declarative UI framework
- **iOS 17.0+** - Target minimum iOS version
- **Xcode 15+** - Development environment
- **Swift 5.9+** - Programming language

### Dependencies & Libraries
- **ReactiveSwift** - Reactive programming for data flow (RxJS-like)
- **ReactiveCocoa** - Reactive bindings for UIKit/SwiftUI
- **SDWebImageSwiftUI** - Image loading and caching
- **PhotosUI** - Native photo picker integration

### Architecture Pattern
- **MVVM (Model-View-ViewModel)** - Clean separation of concerns
- **Repository Pattern** - Data access abstraction
- **Dependency Injection** - Testable and modular code

## App Architecture

### Project Structure
```
Tona/
├── App/
├── Core/
│   ├── Models/
│   ├── Services/
│   ├── Repositories/
│   └── Extensions/
├── Features/
│   ├── PhotoUpload/
│   ├── Processing/
│   └── Results/
├── Shared/
│   ├── Components/
│   ├── DesignSystem/
│   └── Utils/
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

### Core Services
- **PhotoProcessingService** - Handles API communication for image processing
- **APIService** - Manages HTTP requests to backend
- **LocalStorageService** - Saves and loads processed images locally
- **ImagePickerService** - Handles photo selection from device

## UI Components Implementation

### 1. Primary Button
- **Background:** #007AFF
- **Text Color:** #FFFFFF
- **Border Radius:** 12px
- **Padding:** 12px 24px
- **Font:** 17px semibold
- **Min Height:** 48px
- **Disabled State:** #D1D1D6 background, #8E8E93 text

### 2. Secondary Button
- **Background:** Transparent
- **Text Color:** #007AFF
- **Border:** 1px solid #D1D1D6
- **Border Radius:** 12px
- **Padding:** 12px 24px

### 3. Photo Card
- **Background:** #FFFFFF
- **Border Radius:** 16px
- **Padding:** 16px
- **Shadow:** 0 2px 8px rgba(0, 0, 0, 0.1)
- **Aspect Ratio:** 1:1
- **Overflow:** Hidden

### 4. Content Card
- **Background:** #F5F5F5
- **Border Radius:** 12px
- **Padding:** 20px
- **Border:** 2px dashed #D1D1D6

### 5. Upload Area
- **Border:** 2px dashed #D1D1D6
- **Border Radius:** 12px
- **Background:** #F5F5F5
- **Min Height:** 120px
- **Center Content:** True
- **Drag Over State:** #007AFF border, #F0F8FF background

## Screen Implementation

### 1. Main Screen Layout
- **Background:** #F5F5F5
- **Padding:** 20px
- **Safe Area:** True
- **Grid:** 2 columns, 16px gap, responsive
- **Stack:** Vertical, 24px spacing, center alignment

### 2. Navigation
- **Status Bar:** Dark content, transparent background
- **Tab Bar:** #FFFFFF background, 83px height, 0 -1px 0 rgba(0, 0, 0, 0.1) shadow
- **Back Button:** Chevron-left icon, #007AFF color

### 3. Forms
- **Upload Area:** Dashed border with drag over states
- **Input Fields:** Standard iOS styling with design system colors
- **Validation:** Inline error messages with #FF3B30 color

## API Integration

### Endpoints to Implement
1. **Upload First Group** - POST /upload-first-group
2. **Upload Second Group** - POST /upload-second-group
3. **Start Processing** - POST /start-processing
4. **Check Status** - GET /status/{jobId}
5. **Get Result** - GET /result/{jobId}
6. **Cancel Job** - DELETE /cancel/{jobId}

### Request/Response Handling
- **File Upload:** Multipart form data with files[] field
- **Processing Options:** JSON with style, faceEnhancement, targetResolution
- **Status Tracking:** Real-time progress updates
- **Error Handling:** Standard error response format

## User Experience Patterns

### Onboarding
- **Structure:** Multi-step wizard
- **Progression:** Linear
- **Elements:** Hero title, descriptive subtitle, visual content area, primary action button, step indicator

### Photo Processing Workflow
1. **Upload/Capture** - Select photos from device
2. **Processing Indicator** - Show progress with current step
3. **Result Preview** - Display processed images
4. **Edit Options** - Allow adjustments if needed
5. **Save/Share** - Export or share results

### Media Display
- **Grid:** 2-column responsive grid
- **Aspect Ratio:** Square preferred
- **Lazy Loading:** True
- **Placeholder:** Skeleton loading states

## Interactions & Animations

### Transitions
- **Duration:** 0.3s
- **Easing:** Ease-out
- **Page Transitions:** Slide from right

### Gestures
- **Tap:** Standard button interaction
- **Long Press:** Context menus
- **Swipe:** Navigation between screens
- **Pinch Zoom:** Image viewing

### Feedback
- **Haptic:** Light impact on button press
- **Visual:** Scale animation on touch
- **Loading:** Spinner or progress bar

## Accessibility

### Requirements
- **Contrast:** WCAG AA compliant
- **Focus Visible:** Blue outline ring
- **Semantic Labels:** Descriptive aria-labels
- **Dynamic Type:** Supports system font scaling
- **VoiceOver:** Full screen reader support

## Responsive Design

### Breakpoints
- **Mobile:** 320px - 480px
- **Tablet:** 768px - 1024px

### Tablet Adaptations
- **Grid:** 3-4 columns
- **Side Padding:** 48px
- **Modal Width:** 560px

## Iconography

### Style
- **System:** SF Symbols
- **Weight:** Regular to semibold
- **Sizes:** Small (16px), Medium (24px), Large (32px)

### Common Icons
- photo.stack
- camera
- square.and.arrow.up
- checkmark.circle
- xmark.circle

## Implementation Phases

### Phase 1: Foundation
- Design system implementation
- Core UI components
- Basic navigation structure
- ReactiveSwift integration

### Phase 2: Photo Upload
- Image picker integration
- Upload area components
- File validation
- Progress indicators

### Phase 3: API Integration
- HTTP client setup
- Endpoint implementation
- Error handling
- Status tracking

### Phase 4: Results & Polish
- Results display
- Save/share functionality
- Animations and transitions
- Accessibility improvements

This implementation guide provides a clear roadmap for building the Tona iOS app based on the provided design system and API structure.