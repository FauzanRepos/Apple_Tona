# Apple Tona App Overview

## Navigation Flow (Based on Figma and Implementation Guideline)

The app uses a single source of truth for navigation, typically a NavigationStack with a path array. Each screen is represented by an enum or string, and navigation is managed by pushing, popping, or resetting the path.

### Main Screens and Flow

1. **Splash Screen**
   - Shows app logo/animation.
   - On finish: navigates to Tone Gallery.

2. **Tone Gallery (Tone Collection)**
   - Main entry point. Shows a list of tone cards or an empty state.
   - Actions:
     - Add Tone → Upload Preference
     - Select Tone → Upload Photo (with selected tone)

3. **Upload Preference**
   - User uploads reference images for a new tone.
   - On generation complete: navigates to Tone Result.

4. **Tone Result**
   - Shows generated tone preview and allows naming.
   - Actions:
     - Apply to my photos → Upload Photo (with new tone)
     - Save/Discard → Return to Tone Gallery

5. **Upload Photo**
   - User uploads a photo to apply a tone.
   - Actions:
     - Adjust → Adjust Screen
     - Done/Share/Save → Remain on this screen or return to Tone Gallery

6. **Adjust Screen**
   - User adjusts photo (contrast, etc.).
   - Actions:
     - Done/Discard → Return to Upload Photo

7. **Crop Screen** (if implemented)
   - User crops photo.
   - Actions:
     - Done/Discard → Return to Upload Photo

### Notes
- The "Saved Screen" is just an alert, not a full screen.
- All navigation is handled via a single path variable for clarity and maintainability.
- See `.idea/cursor` for implementation guidelines and step-by-step instructions.

---

## Implementation Guideline

See `.idea/cursor` for a step-by-step to-do list and further details on each feature.
