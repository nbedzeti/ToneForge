# Audio Normalization - Quick Test Guide

## ✅ Build Status: SUCCESS
- No compilation errors
- No warnings
- Ready to test

## Quick Test (5 minutes)

### 1. Open in Xcode
```bash
open RingToneMaker.xcodeproj
```

### 2. Run on Simulator
- Select iPhone 17 simulator
- Click Run (⌘R)

### 3. Test Normalization

**Step 1:** Select any audio file
- Tap "Music Library" or "Browse Files"
- Choose a song

**Step 2:** Open Audio Effects
- Tap "Audio Effects" to expand panel
- You should see all controls (Fade In/Out, Volume Boost, Normalize Audio, Equalizer)

**Step 3:** Enable Normalization
- Toggle "Normalize Audio" to ON
- Should show green toggle

**Step 4:** Preview with Effects
- Tap "Preview with Effects" button (purple)
- Should show "Processing..." spinner for 2-5 seconds
- Should play audio with normalization applied

**Step 5:** Check Console Output
- Open Xcode console (⌘⇧Y)
- Look for these messages:
```
🔊 Analyzing audio for normalization...
📊 Peak level: -8.5dB, Normalize boost: 1.95x, Final volume: 1.95x
✅ Effects preview exported to: [temp file path]
```

**Step 6:** Export Ringtone
- Tap "Create Ringtone"
- Should show "Creating..." spinner
- Should show success overlay
- Check console for same analysis output

### Expected Results

✅ **Success Indicators:**
- Toggle works smoothly
- Preview plays with effects
- Console shows analysis output
- Export completes successfully
- Audio is louder if original was quiet

❌ **Failure Indicators:**
- App crashes during preview/export
- No console output
- Audio sounds distorted
- Export hangs indefinitely

## Test Different Scenarios

### Scenario 1: Quiet Audio
- Select a quiet song
- Enable normalization
- Export and listen
- **Expected:** Significantly louder

### Scenario 2: Loud Audio
- Select a loud song
- Enable normalization
- Export and listen
- **Expected:** Similar volume (minimal boost)

### Scenario 3: Combined Effects
- Enable Fade In: 2.0s
- Enable Fade Out: 2.0s
- Set Volume Boost: 150%
- Enable Normalize Audio
- Export and listen
- **Expected:** All effects applied correctly

## Console Output Examples

### Quiet Audio
```
🔊 Analyzing audio for normalization...
📊 Peak level: -12.3dB, Normalize boost: 3.76x, Final volume: 3.76x
```

### Loud Audio
```
🔊 Analyzing audio for normalization...
📊 Peak level: -1.5dB, Normalize boost: 1.12x, Final volume: 1.12x
```

### Already at Target
```
🔊 Analyzing audio for normalization...
📊 Peak level: -0.8dB, Normalize boost: 1.0x, Final volume: 1.0x
```

## Troubleshooting

### No Console Output
- Make sure "Normalize Audio" toggle is ON
- Check that you're using "Preview with Effects" or "Create Ringtone"
- Regular preview doesn't apply effects

### App Crashes
- Check Xcode console for error messages
- Look for memory warnings
- Try with shorter audio clip

### No Volume Change
- Verify toggle is ON (green)
- Check console for boost value
- If boost is 1.0x, audio was already at target level

### Distorted Audio
- Check console for boost value
- Should never exceed 3.98x (12dB limit)
- If distorted, there may be a bug in the limiter

## Performance Notes

- Analysis adds 2-5 seconds to export time
- CPU spike during analysis is normal
- Memory usage should stay reasonable
- No impact on regular playback

## Next Steps After Testing

1. ✅ Test normalization works
2. ✅ Test with different audio files
3. ✅ Test combined with other effects
4. ⚠️ Set `enablePremiumForTesting = false` before production
5. 📱 Upload new build to TestFlight
6. 🎉 Release to users

## Questions to Answer

- [ ] Does normalization make quiet audio louder?
- [ ] Does it avoid over-boosting loud audio?
- [ ] Does it work with other effects?
- [ ] Is the processing time acceptable (2-5 seconds)?
- [ ] Is the audio quality good (no distortion)?
- [ ] Does the console output make sense?

## Report Issues

If you find any issues, note:
1. What audio file you used
2. What settings you had enabled
3. Console output
4. Expected vs actual behavior
