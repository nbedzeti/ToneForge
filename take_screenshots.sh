#!/bin/bash

# ToneForge Studio - Screenshot Helper
# This script helps you take App Store screenshots

echo "📸 ToneForge Studio - Screenshot Helper"
echo "========================================"
echo ""

# Check if simulator is running
if ! pgrep -x "Simulator" > /dev/null; then
    echo "⚠️  Simulator is not running!"
    echo "Please:"
    echo "1. Open Xcode"
    echo "2. Select iPhone 15 Pro Max"
    echo "3. Run the app (Cmd + R)"
    echo "4. Then run this script again"
    exit 1
fi

echo "✅ Simulator is running"
echo ""

# Create screenshots directory
SCREENSHOT_DIR="$HOME/Desktop/ToneForge-Screenshots"
mkdir -p "$SCREENSHOT_DIR"

echo "Screenshots will be saved to:"
echo "$SCREENSHOT_DIR"
echo ""
echo "Instructions:"
echo "1. Navigate to each screen in the simulator"
echo "2. Press ENTER when ready to capture"
echo "3. Repeat for all 5 screenshots"
echo ""
echo "Press Ctrl+C to cancel at any time"
echo ""

# Screenshot 1: Welcome Screen
read -p "📱 Screenshot 1: Welcome/Splash Screen - Press ENTER when ready..."
xcrun simctl io booted screenshot "$SCREENSHOT_DIR/1-welcome.png"
echo "   ✅ Saved: 1-welcome.png"
echo ""

# Screenshot 2: Main Screen
read -p "📱 Screenshot 2: Main Screen/Song Selection - Press ENTER when ready..."
xcrun simctl io booted screenshot "$SCREENSHOT_DIR/2-main.png"
echo "   ✅ Saved: 2-main.png"
echo ""

# Screenshot 3: Waveform Editor
read -p "📱 Screenshot 3: Waveform Editor (KEY FEATURE) - Press ENTER when ready..."
xcrun simctl io booted screenshot "$SCREENSHOT_DIR/3-waveform.png"
echo "   ✅ Saved: 3-waveform.png"
echo ""

# Screenshot 4: Effects Panel
read -p "📱 Screenshot 4: Audio Effects/Premium Features - Press ENTER when ready..."
xcrun simctl io booted screenshot "$SCREENSHOT_DIR/4-effects.png"
echo "   ✅ Saved: 4-effects.png"
echo ""

# Screenshot 5: Library
read -p "📱 Screenshot 5: Ringtone Library - Press ENTER when ready..."
xcrun simctl io booted screenshot "$SCREENSHOT_DIR/5-library.png"
echo "   ✅ Saved: 5-library.png"
echo ""

echo "🎉 All screenshots captured!"
echo ""
echo "📁 Location: $SCREENSHOT_DIR"
echo ""

# Check dimensions
echo "Checking dimensions..."
for file in "$SCREENSHOT_DIR"/*.png; do
    if [ -f "$file" ]; then
        dimensions=$(sips -g pixelWidth -g pixelHeight "$file" | grep -E "pixelWidth|pixelHeight" | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
        filename=$(basename "$file")
        echo "   $filename: ${dimensions}px"
    fi
done

echo ""
echo "✅ App Store accepts: 1284×2778, 1290×2796, or 1242×2688"
echo ""
echo "Next steps:"
echo "1. Open Finder and go to Desktop/ToneForge-Screenshots"
echo "2. Review all screenshots"
echo "3. Upload to App Store Connect"
echo ""
echo "Done! 🚀"
