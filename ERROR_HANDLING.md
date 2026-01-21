# Error Handling Documentation

This document describes all error handling implemented in the RingToneMaker app.

## Error Types

### AudioError

Custom error type for audio loading and validation issues.

**Cases:**
- `noAudioTrack` - Selected file contains no audio track
- `unsupportedFormat` - Audio format is not supported
- `invalidDuration` - Unable to determine audio duration (corrupted file)
- `loadFailed(String)` - Generic load failure with details

**User Messages:**
- Clear, actionable error descriptions
- Suggests selecting a different song when format is unsupported
- Indicates potential file corruption

### ExportError

Custom error type for export and file operation issues.

**Cases:**
- `invalidTimeRange` - Start time is not before end time
- `sessionCreationFailed` - Cannot create AVAssetExportSession
- `exportFailed(String)` - Export process failed with details
- `fileOperationFailed(String)` - File system operation failed
- `cancelled` - User or system cancelled the export
- `unknownError` - Unexpected error during export
- `unexpectedStatus(Int)` - Export ended with unexpected status code

**User Messages:**
- Specific error descriptions for each failure type
- Suggests retry when appropriate
- Provides technical details for debugging

## Validation & Error Scenarios

### 1. Music Library Permission

**Scenarios:**
- Permission not determined → Request permission
- Permission denied → Guide user to Settings
- Permission restricted → Inform user of restriction

**User Guidance:**
- Exact path to Settings: "Settings > Privacy > Media & Apple Music"
- Clear explanation of why permission is needed

### 2. Audio Loading

**Validations:**
- Audio track exists
- Format is supported
- Duration is valid and finite
- File is not corrupted

**Error Handling:**
- Shows alert with specific error
- Prevents further operations until valid audio is loaded
- Resets UI state on failure

### 3. Time Input Validation

**Text Field Validation:**
- Checks for valid number format
- Ensures non-negative values
- Validates against song duration
- Maintains start < end constraint
- Enforces 30-second maximum duration

**Automatic Adjustments:**
- Clamps values to valid ranges
- Auto-adjusts opposite time when constraint violated
- Shows alert explaining adjustments

**Error Messages:**
- "Invalid Input" - Non-numeric entry
- "Invalid Time" - Negative or out-of-range value
- "Duration Adjusted" - Auto-correction applied

### 4. Slider Validation

**Real-time Constraints:**
- Start slider: 0 to (duration - 1)
- End slider: 0 to duration
- Automatic adjustment of opposite slider
- Smooth, continuous updates

**No Errors:**
- Sliders are constrained by design
- Cannot produce invalid values

### 5. Audio Preview

**Validations:**
- Valid audio URL exists
- Selection range is valid
- Audio file is accessible

**Error Handling:**
- Shows alert if preview cannot start
- Provides specific error from AVAudioPlayer
- Stops playback on time changes

### 6. Export Process

**Pre-Export Validation:**
- Valid audio asset exists
- Time range is valid
- Duration doesn't exceed 30 seconds

**During Export:**
- Monitors export session status
- Handles all possible status codes
- Cleans up temporary files on failure

**Post-Export:**
- Verifies file was created
- Handles file rename operation
- Cleans up on any failure

**Error Recovery:**
- Removes temporary files
- Resets export state
- Allows retry

### 7. File Operations

**Share Validation:**
- Verifies file exists before sharing
- Checks file path accessibility
- Handles missing file gracefully

**Delete Operation:**
- Catches file system errors
- Provides feedback on success/failure
- Updates UI state appropriately

**File Listing:**
- Handles directory access errors
- Returns empty array on failure
- Logs errors for debugging

## Alert System

### Dynamic Alert Titles

The app uses contextual alert titles:
- "Success" - Successful operations
- "Error" - Generic errors
- "Cannot Export" - Export validation failures
- "Export Failed" - Export process failures
- "Permission Required" - Permission issues
- "Permission Denied" - Permission explicitly denied
- "Invalid Input" - User input errors
- "Invalid Time" - Time validation errors
- "Duration Adjusted" - Automatic adjustments
- "Cannot Play" - Playback errors
- "Playback Error" - Audio player errors
- "Audio Error" - Audio loading errors
- "No File" - Missing file errors
- "File Not Found" - File system errors
- "Delete Failed" - Delete operation errors

### Alert Messages

All alert messages:
- Use clear, non-technical language
- Explain what went wrong
- Suggest corrective action when possible
- Provide specific details for debugging
- Include relevant values (durations, file names, etc.)

## User Experience

### Progressive Disclosure

1. **Prevention** - UI constraints prevent many errors
   - Sliders have built-in ranges
   - Buttons disabled when invalid
   - Real-time validation

2. **Validation** - Catch errors before operations
   - Text field validation on change
   - Pre-export checks
   - File existence verification

3. **Recovery** - Handle errors gracefully
   - Clear error messages
   - Automatic cleanup
   - Allow retry without restart

### Visual Feedback

- Red text for validation errors
- Disabled buttons for invalid states
- Color-coded status indicators
- Progress indicators during operations

### Accessibility

- All errors announced via alerts
- VoiceOver compatible error messages
- Clear visual indicators
- Keyboard-friendly error handling

## Testing Error Scenarios

### How to Test Each Error Type

1. **No Audio Track**
   - Select a video file (if possible)
   - Expected: "No audio track found" error

2. **Unsupported Format**
   - Select a DRM-protected song
   - Expected: Format error or access denied

3. **Invalid Duration**
   - Select a corrupted audio file
   - Expected: "Unable to determine audio duration" error

4. **Permission Denied**
   - Deny media library permission
   - Try to select song
   - Expected: Permission guidance alert

5. **Invalid Time Input**
   - Enter negative number in time field
   - Enter text instead of number
   - Enter time > song duration
   - Expected: Specific validation error for each

6. **Export Failure**
   - Fill device storage completely
   - Try to export
   - Expected: File operation error

7. **Missing File**
   - Export a ringtone
   - Manually delete the file
   - Try to share
   - Expected: "File not found" error

## Best Practices Implemented

1. **Fail Fast** - Validate early, before expensive operations
2. **Fail Gracefully** - Never crash, always show user-friendly message
3. **Fail Informatively** - Provide actionable error messages
4. **Fail Safely** - Clean up resources on failure
5. **Fail Recoverably** - Allow user to retry or correct

## Future Enhancements

Potential error handling improvements:
- Retry mechanism for network-related errors
- Error logging for analytics
- Offline error queue
- More granular audio format detection
- Automatic format conversion for unsupported files
