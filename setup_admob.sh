#!/bin/bash

# AdMob Setup Script for RingToneMaker
# This script helps you set up Google AdMob integration

echo "🎯 RingToneMaker - AdMob Setup Script"
echo "======================================"
echo ""

# Check if we're in the right directory
if [ ! -f "RingToneMaker.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Please run this script from the RingToneMaker directory"
    exit 1
fi

echo "📋 Setup Options:"
echo "1. Install via Swift Package Manager (Recommended)"
echo "2. Install via CocoaPods"
echo "3. Skip installation (I'll do it manually)"
echo ""
read -p "Choose option (1-3): " option

case $option in
    1)
        echo ""
        echo "✅ Swift Package Manager selected"
        echo ""
        echo "📝 Follow these steps in Xcode:"
        echo "1. Open RingToneMaker.xcodeproj"
        echo "2. Go to File > Add Package Dependencies"
        echo "3. Enter URL: https://github.com/googleads/swift-package-manager-google-mobile-ads.git"
        echo "4. Select version 11.0.0 or later"
        echo "5. Click Add Package"
        echo ""
        read -p "Press Enter when done..."
        ;;
    2)
        echo ""
        echo "✅ CocoaPods selected"
        echo ""
        
        # Check if CocoaPods is installed
        if ! command -v pod &> /dev/null; then
            echo "❌ CocoaPods not found. Installing..."
            sudo gem install cocoapods
        fi
        
        echo "📦 Installing pods..."
        pod install
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ Pods installed successfully!"
            echo "⚠️  IMPORTANT: Use RingToneMaker.xcworkspace (not .xcodeproj) from now on"
        else
            echo ""
            echo "❌ Pod installation failed. Please run 'pod install' manually."
            exit 1
        fi
        ;;
    3)
        echo ""
        echo "✅ Skipping installation"
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "📝 Next Steps:"
echo "=============="
echo ""
echo "1. Create AdMob Account:"
echo "   → Go to https://admob.google.com"
echo "   → Sign in and create an account"
echo ""
echo "2. Add Your App:"
echo "   → Click 'Apps' > 'Add App'"
echo "   → Select iOS"
echo "   → Enter app name: RingToneMaker"
echo "   → Copy your App ID (ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY)"
echo ""
echo "3. Create Rewarded Ad Unit:"
echo "   → Click 'Ad units' > 'Add Ad Unit'"
echo "   → Select 'Rewarded'"
echo "   → Enter name: Ringtone Unlock Reward"
echo "   → Copy your Ad Unit ID (ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY)"
echo ""
echo "4. Update Info.plist:"
echo "   → Replace GADApplicationIdentifier with your App ID"
echo ""
echo "5. Update AdManager.swift:"
echo "   → Replace productionAdUnitID with your Ad Unit ID"
echo ""
echo "6. Build and Test:"
echo "   → Open project in Xcode"
echo "   → Build (Cmd+B)"
echo "   → Run (Cmd+R)"
echo "   → Check console for: '✅ Google Mobile Ads SDK initialized'"
echo ""
echo "📚 Full guide: ADMOB_INTEGRATION_GUIDE.md"
echo ""
echo "✅ Setup complete! Happy coding! 🚀"
