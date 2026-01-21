# RingToneMaker

An iOS app built with SwiftUI for creating custom ringtones from your music library.

## Features

- **Music Library Integration**: Select songs from your music library using MediaPlayer framework
- **Interactive Waveform Visualization**: 
  - View audio waveform with real-time selection highlighting
  - Pinch to zoom (up to 3x magnification)
  - Drag to pan across the waveform
  - Visual zoom indicator
- **Flexible Time Selection**: 
  - Text fields for precise time entry
  - Stepper buttons for quick adjustments
  - Sliders for smooth, continuous control
  - Bidirectional sync between all input methods
- **Audio Preview**: Play the selected portion before exporting
- **Audio Trimming**: Export trimmed audio segments using AVAssetExportSession
- **M4R Export**: Save ringtones as M4R files (iPhone ringtone format)
- **Share Functionality**: Share or save exported ringtones via iOS share sheet
- **Comprehensive Error Handling**:
  - Invalid time range validation with helpful messages
  - Audio format compatibility checks
  - Permission denial guidance
  - Export failure recovery
  - File operation error handling
- **Validation**: Automatic validation for 30-second ringtone limit with duration capping

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.0+

## Documentation

- **[Quick Start Guide](QUICK_START.md)** - Get started in 5 easy steps
- **[Installation Guide](RINGTONE_INSTALLATION.md)** - Detailed ringtone installation instructions
- **[Set Ringtone Guide](SET_RINGTONE_GUIDE.md)** - How to set your ringtone in iOS Settings
- **[Error Handling](ERROR_HANDLING.md)** - Complete error reference
- **[Testing Plan](TESTING_PLAN.md)** - Comprehensive testing strategy
- **[App Store Submission](APP_STORE_SUBMISSION.md)** - Submission guide and requirements
- **[Monetization Plan](MONETIZATION_PLAN.md)** - Revenue model and implementation
- **[Monetization Summary](MONETIZATION_SUMMARY.md)** - Quick reference

## Getting Started

1. Open `RingToneMaker.xcodeproj` in Xcode
2. Select your development team in the project settings
3. Build and run on a device or simulator
4. See [QUICK_START.md](QUICK_START.md) for user instructions

## How to Use

1. **Select a Song**: Tap "Select Song from Library" and choose a song from your music library
2. **View Waveform**: The app displays the audio waveform with the full song
   - Pinch to zoom in/out (up to 3x)
   - Drag to pan left/right when zoomed
3. **Set Time Range**: 
   - Use text fields to enter precise start and end times (in seconds)
   - Use stepper buttons for quick adjustments
   - Use sliders for smooth, continuous control
   - All three methods sync automatically
   - Maximum ringtone duration is 30 seconds
4. **Preview**: Tap the "Preview" button to hear your selected segment
5. **Export**: Tap "Trim & Export Ringtone" to create your ringtone
6. **Share**: Once exported, use the "Share as Ringtone" button to:
   - Save to Files app
   - Share via AirDrop to your Mac
   - Send via Email or Messages
   - Delete the file when done

## Installing Your Ringtone

After creating your M4R file, you'll need to install it on your iPhone. See:
- **[RINGTONE_INSTALLATION.md](RINGTONE_INSTALLATION.md)** - Detailed installation methods
- **[SET_RINGTONE_GUIDE.md](SET_RINGTONE_GUIDE.md)** - Step-by-step guide with screenshots

**Quick Summary:**
1. Export ringtone in RingToneMaker
2. Share via AirDrop to Mac or save to Files
3. Sync to iPhone using Finder (Mac) or iTunes (PC)
4. Set in Settings > Sounds & Haptics > Ringtone

**Alternative:** Use GarageBand method (no computer required)

## Permissions

The app requires access to your music library. The permission request is handled automatically when you tap "Select Song from Library".

## Project Structure

```
RingToneMaker/
├── RingToneMaker/
│   ├── RingToneMakerApp.swift    # Main app entry point
│   ├── ContentView.swift          # Main UI view with controls
│   ├── WaveformView.swift         # Custom waveform visualization
│   ├── Assets.xcassets/           # App assets and icons
│   └── Info.plist                 # App configuration
└── RingToneMaker.xcodeproj/       # Xcode project file
```

## Technical Details

- **Audio Processing**: AVFoundation framework for audio loading and processing
- **Waveform**: Custom SwiftUI view using AVAssetReader to extract PCM samples
  - Interactive gestures: MagnificationGesture for zoom, DragGesture for pan
  - Real-time visual feedback with smooth animations
- **Export**: AVAssetExportSession with CMTime-based trimming
- **File Format**: M4R (iPhone ringtone format, structurally identical to M4A/AAC)
- **Duration Capping**: Automatically limits export to 30 seconds maximum
- **Storage**: Exported files saved to app's Documents directory with unique timestamps
- **Error Handling**: Custom error types (AudioError, ExportError) with localized descriptions

## Testing

See [TESTING_PLAN.md](TESTING_PLAN.md) for comprehensive testing strategy including:
- Simulator testing on multiple devices
- Real device testing requirements
- Edge cases and stress testing
- Beta testing guidelines
- Pre-release checklist

**Quick Test:**
1. Run on iPhone with music library
2. Grant permission when prompted
3. Select a song
4. Adjust times and preview
5. Export and share

## App Store Submission

See [APP_STORE_SUBMISSION.md](APP_STORE_SUBMISSION.md) for complete submission guide including:
- Required capabilities and permissions
- App Store Connect setup
- Screenshots and descriptions
- Privacy policy requirements
- Review notes and tips

## Limitations

- Only works with downloaded songs (DRM-protected or cloud-only songs cannot be accessed)
- Maximum ringtone duration: 30 seconds (automatically capped during export)
- Requires music library permission
- M4R files can be shared but require iTunes/Finder sync to install as actual ringtones on iOS devices
- This is an iOS platform limitation, not an app limitation

## Future Enhancements

- Fade in/out effects
- Volume adjustment
- Multiple format support (MP3, WAV)
- Direct ringtone installation (requires additional configuration)
- Batch processing
