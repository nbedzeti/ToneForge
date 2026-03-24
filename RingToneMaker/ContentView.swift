//
//  ContentView.swift
//  RingToneMaker
//
//  Two-screen design: Selection → Editor
//  Black background, green text, orange waveform
//

import SwiftUI
import MediaPlayer
import AVFoundation
import AVKit
import UniformTypeIdentifiers

struct ContentView: View {
    @Bindable var purchaseManager: PurchaseManager
    
    @State private var showingSplash = true
    @State private var showingMediaPicker = false
    @State private var showingDocumentPicker = false
    @State private var selectedSongTitle: String = "No song selected"
    @State private var selectedAudioURL: URL?
    @State private var audioAsset: AVAsset?
    @State private var audioDuration: TimeInterval = 0
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Notice"
    @State private var isAudioLoaded = false
    
    @State private var startTimeText: String = "0:00"
    @State private var endTimeText: String = "0:30"
    @State private var startTime: Double = 0
    @State private var endTime: Double = 30
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var playbackTimer: Timer?
    @State private var currentPlaybackTime: Double = 0
    @State private var avPlayer: AVPlayer?
    
    @State private var isExporting = false
    @State private var exportedFileURL: URL?
    @State private var showShareSheet = false
    
    @State private var showingPremiumView = false
    @State private var showingNumberPad = false
    @State private var editingStartTime = false
    
    // Premium features
    @State private var audioEffects = AudioProcessor.AudioEffects()
    @State private var showingAudioEffects = false
    @State private var ringtoneLibrary = RingtoneLibrary()
    @State private var showingLibrary = false
    @State private var showingRadio = false
    @State private var showingSaveDialog = false
    @State private var ringtoneName = ""
    @State private var isPreviewingEffects = false
    @State private var radioPlayerManager = RadioPlayerManager()
    
    private let maxRingtoneDuration: Double = 30
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if showingSplash {
                SplashScreenView(onComplete: {
                    showingSplash = false
                })
            } else {
                mainContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var mainContent: some View {
        ZStack {
            if isAudioLoaded {
                // SCREEN 2: Editor
                editorScreen
            } else {
                // SCREEN 1: Selection
                selectionScreen
            }
            
            // Custom Save to Library Dialog
            if showingSaveDialog {
                ZStack {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingSaveDialog = false
                        }
                    
                    VStack(spacing: 20) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        Text("Save to Library")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Give your ringtone a name")
                            .font(.subheadline)
                            .foregroundColor(.green.opacity(0.7))
                        
                        TextField("Ringtone Name", text: $ringtoneName)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                showingSaveDialog = false
                            }) {
                                Text("Cancel")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.green, lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            Button(action: {
                                if let url = exportedFileURL {
                                    do {
                                        try ringtoneLibrary.saveRingtone(from: url, name: ringtoneName)
                                        alertTitle = "Success"
                                        alertMessage = "Ringtone saved to library!"
                                        showingAlert = true
                                    } catch {
                                        alertTitle = "Error"
                                        alertMessage = "Failed to save: \(error.localizedDescription)"
                                        showingAlert = true
                                    }
                                }
                                showingSaveDialog = false
                            }) {
                                Text("Save")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(ringtoneName.isEmpty)
                            .opacity(ringtoneName.isEmpty ? 0.5 : 1.0)
                        }
                    }
                    .padding(30)
                    .background(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.green, lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .frame(maxWidth: 340)
                    .padding(.horizontal, 40)
                    .shadow(color: .green.opacity(0.3), radius: 20)
                }
                .transition(.opacity)
                .zIndex(2000)
            }
        }
        .overlay(alignment: .bottom) {
            if radioPlayerManager.isPlaying || radioPlayerManager.isBuffering,
               let station = radioPlayerManager.currentStation {
                nowPlayingFloatingBar(station: station)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showingMediaPicker) {
            MediaPickerView(
                selectedSongTitle: $selectedSongTitle,
                selectedAudioURL: $selectedAudioURL,
                onSongSelected: { url in
                    loadAudioAsset(from: url)
                }
            )
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPickerView(
                selectedSongTitle: $selectedSongTitle,
                selectedAudioURL: $selectedAudioURL,
                onFileSelected: { url in
                    loadAudioAsset(from: url)
                }
            )
        }
        .fullScreenCover(isPresented: $showingPremiumView) {
            PurchaseView(purchaseManager: purchaseManager)
        }
        .fullScreenCover(isPresented: $showingLibrary) {
            RingtoneLibraryView(
                library: ringtoneLibrary,
                isPremium: purchaseManager.isPremium,
                onUpgrade: { showingPremiumView = true }
            )
        }
        .fullScreenCover(isPresented: $showingRadio) {
            RadioView(purchaseManager: purchaseManager, playerManager: radioPlayerManager) { clipURL in
                showingRadio = false
                loadAudioAsset(from: clipURL)
                selectedSongTitle = "Radio Clip"
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(items: [url])
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onDisappear {
            stopPreview()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Selection Screen
    
    private var selectionScreen: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let isTablet = min(geometry.size.width, geometry.size.height) > 600
            let maxContentWidth: CGFloat = isTablet ? 600 : .infinity
            let hPad = isTablet ? (geometry.size.width - 600) / 2 : geometry.size.width * 0.04
            let buttonVPad = max(9, geometry.size.height * 0.012)
            let sectionSpacing = isLandscape ? max(6, geometry.size.height * 0.015) : max(10, geometry.size.height * 0.018)
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header — proportional top spacing
                    VStack(spacing: isLandscape ? 2 : max(4, geometry.size.height * 0.008)) {
                        if !isLandscape {
                            Image(systemName: "waveform.circle.fill")
                                .font(.system(size: isTablet ? 64 : min(70, geometry.size.width * 0.18)))
                                .foregroundColor(.green)
                                .shadow(color: .green.opacity(0.5), radius: 15)
                        }
                        
                        Text("ToneForge Studio")
                            .font(.system(size: isTablet ? 32 : min(32, geometry.size.width * 0.08), weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                        
                        if !isLandscape {
                            Text("Your Phone, Your Ringtone")
                                .font(.callout)
                                .foregroundColor(.green.opacity(0.7))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, geometry.safeAreaInsets.top)
                    .padding(.bottom, sectionSpacing)
                    
                    // Buttons section — fills remaining space proportionally
                    if isLandscape {
                        // Landscape: 2x2 grid
                        VStack(spacing: sectionSpacing) {
                            HStack(spacing: 8) {
                                VStack(spacing: 8) {
                                    selectionButton(icon: "music.note.list", title: "My Music Library", subtitle: "Choose a song to edit", vPad: buttonVPad) {
                                        requestMediaLibraryAccess()
                                    }
                                    selectionButton(icon: "rectangle.stack.fill", title: "My Ringtones", subtitle: "View saved ringtones", badge: !purchaseManager.isPremium ? "crown.fill" : nil, count: ringtoneLibrary.ringtones.count, vPad: buttonVPad) {
                                        showingLibrary = true
                                    }
                                }
                                VStack(spacing: 8) {
                                    selectionButton(icon: "folder.fill", title: "Import Audio File", subtitle: "Browse your files", vPad: buttonVPad) {
                                        showingDocumentPicker = true
                                    }
                                    selectionButton(icon: "radio.fill", title: "World Radio", subtitle: "Stream worldwide stations", badge: !purchaseManager.isPremium ? "crown.fill" : nil, vPad: buttonVPad) {
                                        showingRadio = true
                                    }
                                }
                            }
                            .frame(maxWidth: maxContentWidth)
                            
                            if !purchaseManager.isPremium {
                                Button(action: { showingPremiumView = true }) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                        Text("Upgrade to Premium")
                                        Spacer()
                                        if purchaseManager.remainingFreeCreations > 0 {
                                            Text("\(purchaseManager.remainingFreeCreations) Free Left")
                                                .font(.caption2)
                                                .foregroundColor(.black.opacity(0.7))
                                        }
                                        Image(systemName: "chevron.right")
                                    }
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.black)
                                    .padding(.vertical, buttonVPad)
                                    .padding(.horizontal, 14)
                                    .frame(maxWidth: maxContentWidth)
                                    .background(Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                        .padding(.horizontal, max(hPad, 8))
                        .frame(maxWidth: .infinity)
                    } else {
                        // Portrait: vertical list with proportional spacing
                        VStack(spacing: sectionSpacing) {
                            VStack(spacing: max(6, geometry.size.height * 0.008)) {
                                selectionButton(icon: "music.note.list", title: "My Music Library", subtitle: "Choose a song to edit", vPad: buttonVPad) {
                                    requestMediaLibraryAccess()
                                }
                                
                                selectionButton(icon: "folder.fill", title: "Import Audio File", subtitle: "Browse your files", vPad: buttonVPad) {
                                    showingDocumentPicker = true
                                }
                            }
                            .frame(maxWidth: maxContentWidth)
                            
                            if !purchaseManager.isPremium {
                                VStack(spacing: max(6, geometry.size.height * 0.008)) {
                                    if purchaseManager.remainingFreeCreations > 0 {
                                        HStack {
                                            Image(systemName: "gift.fill")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                            Text("\(purchaseManager.remainingFreeCreations) Free Left")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                            Spacer()
                                        }
                                        .padding(.vertical, buttonVPad * 0.8)
                                        .padding(.horizontal, 14)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.green.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    
                                    Button(action: { showingPremiumView = true }) {
                                        HStack {
                                            Image(systemName: "star.fill")
                                            Text("Upgrade to Premium")
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                        }
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.black)
                                        .padding(.vertical, buttonVPad)
                                        .padding(.horizontal, 14)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.green)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                                .frame(maxWidth: maxContentWidth)
                            }
                            
                            selectionButton(icon: "rectangle.stack.fill", title: "My Ringtones", subtitle: "View saved ringtones", badge: !purchaseManager.isPremium ? "crown.fill" : nil, count: ringtoneLibrary.ringtones.count, vPad: buttonVPad) {
                                showingLibrary = true
                            }
                            .frame(maxWidth: maxContentWidth)
                            
                            selectionButton(icon: "radio.fill", title: "World Radio", subtitle: "Stream worldwide stations", badge: !purchaseManager.isPremium ? "crown.fill" : nil, vPad: buttonVPad) {
                                showingRadio = true
                            }
                            .frame(maxWidth: maxContentWidth)
                        }
                        .padding(.horizontal, hPad)
                        .frame(maxWidth: .infinity)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .top)
        }
    }
    
    // Reusable compact selection button — vPad scales with screen
    private func selectionButton(icon: String, title: String, subtitle: String, badge: String? = nil, count: Int = 0, vPad: CGFloat = 9, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(.green)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 4) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.green)
                        if let badge = badge {
                            Image(systemName: badge)
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                        if count > 0 {
                            Text("(\(count))")
                                .font(.caption2)
                                .foregroundColor(.green.opacity(0.7))
                        }
                    }
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.green.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.green.opacity(0.5))
            }
            .padding(.vertical, vPad)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(Color.green.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // Floating "Now Playing" bar — visible on all screens
    @State private var marqueeOffset: CGFloat = 0
    
    private func nowPlayingFloatingBar(station: RadioStation) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            Button(action: { showingRadio = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "radio.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    
                    Text("Now Playing: \(station.displayName)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if radioPlayerManager.isBuffering {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                            .scaleEffect(0.5)
                            .frame(width: 16, height: 16)
                    } else {
                        Image(systemName: "waveform")
                            .font(.caption2)
                            .foregroundColor(.green.opacity(0.6))
                    }
                    
                    Button(action: { radioPlayerManager.stop() }) {
                        Image(systemName: "stop.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green.opacity(0.6))
                    }
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 12)
                .frame(maxWidth: 700)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .overlay(
                Rectangle()
                    .fill(Color.green.opacity(0.3))
                    .frame(height: 1),
                alignment: .top
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: - Editor Screen
    
    private var editorScreen: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let isTablet = min(geometry.size.width, geometry.size.height) > 600
            let maxContentWidth: CGFloat = isTablet ? 700 : .infinity
            let hPad = isTablet ? max((geometry.size.width - 700) / 2, 16) : geometry.size.width * 0.04
            let waveformHeight = isLandscape ? geometry.size.height * 0.2 : geometry.size.height * 0.12
            let btnVPad = max(8, geometry.size.height * 0.012)
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header — sits below safe area
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Text("Create Your New Ringtone")
                                .font(.subheadline)
                                .foregroundColor(.green.opacity(0.7))
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        
                        Rectangle()
                            .fill(Color.green.opacity(0.2))
                            .frame(height: 0.5)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .padding(.top, max(geometry.safeAreaInsets.top - 59, 0))
                    .zIndex(10)
                    
                    ScrollView(showsIndicators: true) {
                        VStack(spacing: max(6, geometry.size.height * 0.008)) {
                            // Song title
                            Text(selectedSongTitle)
                                .font(.caption)
                                .foregroundColor(.green.opacity(0.7))
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                            
                            // Waveform
                            if let asset = audioAsset {
                                VStack(spacing: 4) {
                                    WaveformView(
                                        audioAsset: asset,
                                        startTime: startTime,
                                        endTime: endTime,
                                        totalDuration: audioDuration,
                                        isPlaying: isPlaying,
                                        audioPlayer: audioPlayer
                                    )
                                    .frame(height: max(60, waveformHeight))
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .background(Color.green.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    // Playback progress indicator
                                    PlaybackProgressView(
                                        currentTime: currentPlaybackTime,
                                        totalDuration: audioDuration,
                                        onSeek: { time in
                                            seekToTime(time)
                                        }
                                    )
                                    
                                    // Preview buttons - all in one row
                                    HStack(spacing: 6) {
                                        // Preview full song
                                        Button(action: {
                                            if isPlaying {
                                                stopPreview()
                                            } else {
                                                playPreview()
                                            }
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                                    .font(.caption)
                                                Text(isPlaying ? "Stop" : "Full")
                                                    .font(.caption2)
                                            }
                                            .foregroundColor(.green)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, btnVPad)
                                            .background(Color.green.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                            )
                                        }
                                        
                                        // Preview selected portion
                                        Button(action: {
                                            if isPlaying {
                                                stopPreview()
                                            } else {
                                                playSelectedPortion()
                                            }
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                                    .font(.caption)
                                                Text(isPlaying ? "Stop" : "Selection")
                                                    .font(.caption2)
                                            }
                                            .foregroundColor(.orange)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, btnVPad)
                                            .background(Color.orange.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                            )
                                        }
                                        
                                        // Preview with effects (Premium only)
                                        if purchaseManager.isPremium {
                                            Button(action: {
                                                if hasEffectsEnabled {
                                                    if isPlaying {
                                                        stopPreview()
                                                    } else {
                                                        playPreviewWithEffects()
                                                    }
                                                } else {
                                                    withAnimation {
                                                        showingAudioEffects = true
                                                    }
                                                }
                                            }) {
                                                HStack(spacing: 4) {
                                                    if isPreviewingEffects {
                                                        ProgressView()
                                                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                                                            .scaleEffect(0.7)
                                                    } else {
                                                        Image(systemName: hasEffectsEnabled ? "waveform.circle.fill" : "wand.and.stars")
                                                            .font(.caption)
                                                    }
                                                    Text(isPreviewingEffects ? "..." : "Effects")
                                                        .font(.caption2)
                                                }
                                                .foregroundColor(hasEffectsEnabled ? .purple : .purple.opacity(0.7))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, btnVPad)
                                                .background(hasEffectsEnabled ? Color.purple.opacity(0.1) : Color.purple.opacity(0.05))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(hasEffectsEnabled ? Color.purple.opacity(0.3) : Color.purple.opacity(0.2), lineWidth: 1)
                                                )
                                            }
                                            .disabled(isPreviewingEffects)
                                        }
                                    }
                                }
                                .padding(.horizontal, hPad)
                            }
                            
                            // Audio Effects (Premium feature)
                            AudioEffectsView(
                                effects: $audioEffects,
                                isExpanded: $showingAudioEffects,
                                isPremium: purchaseManager.isPremium,
                                onUpgrade: { showingPremiumView = true }
                            )
                            .padding(.horizontal, hPad)
                            
                            // Time controls
                            VStack(spacing: 4) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Start")
                                            .font(.caption2)
                                            .foregroundColor(.green.opacity(0.7))
                                        Text(startTimeText)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                            .frame(minWidth: 60, maxWidth: 100)
                                            .padding(.vertical, 5)
                                            .background(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                            .onTapGesture {
                                                startTimeText = ""
                                                editingStartTime = true
                                                showingNumberPad = true
                                            }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("End")
                                            .font(.caption2)
                                            .foregroundColor(.green.opacity(0.7))
                                        Text(endTimeText)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                            .frame(minWidth: 60, maxWidth: 100)
                                            .padding(.vertical, 5)
                                            .background(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                            .onTapGesture {
                                                endTimeText = ""
                                                editingStartTime = false
                                                showingNumberPad = true
                                            }
                                    }
                                }
                                
                                let duration = endTime - startTime
                                HStack {
                                    Text("Duration: \(formatDuration(duration))")
                                        .font(.caption2)
                                        .foregroundColor(duration <= maxRingtoneDuration ? .green : .red)
                                    
                                    if duration > maxRingtoneDuration {
                                        Text("(Max 30s)")
                                            .font(.caption2)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal, hPad)
                            
                            // Export + Back in a row
                            HStack(spacing: 8) {
                                // Back button
                                Button(action: {
                                    isAudioLoaded = false
                                    selectedAudioURL = nil
                                    audioAsset = nil
                                    selectedSongTitle = "No song selected"
                                    stopPreview()
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "chevron.left")
                                            .font(.caption)
                                        Text("Back")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.green)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, btnVPad)
                                    .background(Color.green.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                
                                // Export button
                                Button(action: { handleExport() }) {
                                    HStack(spacing: 4) {
                                        if isExporting {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                                .scaleEffect(0.8)
                                            Text("Creating...")
                                                .font(.caption)
                                        } else {
                                            Image(systemName: "scissors")
                                                .font(.caption)
                                            Text("Create Ringtone")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                        }
                                    }
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, btnVPad)
                                    .background(Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .disabled(isExporting || (endTime - startTime) > maxRingtoneDuration)
                            }
                            .padding(.horizontal, hPad)
                        }
                        .frame(maxWidth: maxContentWidth)
                        .frame(maxWidth: .infinity)
                        .padding(.top, max(4, geometry.size.height * 0.005))
                        .padding(.bottom, max(8, geometry.size.height * 0.01))
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Scroll indicator line on right side
                VStack {
                    Spacer()
                        .frame(height: 80)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 3, height: 140)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 4)
                .allowsHitTesting(false)
                
                // Success overlay - appears on top
                if exportedFileURL != nil {
                    ZStack {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                            .onTapGesture {
                                exportedFileURL = nil
                            }
                        
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("Ringtone Created!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Text("Your ringtone is ready to use")
                                .font(.subheadline)
                                .foregroundColor(.green.opacity(0.7))
                            
                            Button(action: { showShareSheet = true }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Ringtone")
                                }
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            if purchaseManager.isPremium {
                                Button(action: {
                                    // Clean up the song title for default name
                                    var cleanName = selectedSongTitle
                                    let extensionsToRemove = [".mp3", ".m4a", ".m4r", ".wav", ".aac"]
                                    for ext in extensionsToRemove {
                                        if cleanName.lowercased().hasSuffix(ext) {
                                            cleanName = String(cleanName.dropLast(ext.count))
                                        }
                                    }
                                    ringtoneName = cleanName
                                    showingSaveDialog = true
                                }) {
                                    HStack {
                                        Image(systemName: "folder.badge.plus")
                                        Text("Save to Library")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.green, lineWidth: 2)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            
                            Button(action: { exportedFileURL = nil }) {
                                Text("Done")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                                    .padding(.top, 8)
                            }
                        }
                        .padding(30)
                        .background(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.green, lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 40)
                        .shadow(color: .green.opacity(0.3), radius: 20)
                    }
                    .transition(.opacity)
                    .zIndex(1000)
                }
                
                // Custom number pad overlay
                if showingNumberPad {
                    VStack {
                        Spacer()
                        if editingStartTime {
                            CustomNumberPad(
                                text: $startTimeText,
                                onDone: {
                                    validateStartTime()
                                    showingNumberPad = false
                                }
                            )
                            .transition(.move(edge: .bottom))
                        } else {
                            CustomNumberPad(
                                text: $endTimeText,
                                onDone: {
                                    validateEndTime()
                                    showingNumberPad = false
                                }
                            )
                            .transition(.move(edge: .bottom))
                        }
                    }
                    .background(Color.black.opacity(0.5))
                    .onTapGesture {
                        if editingStartTime {
                            validateStartTime()
                        } else {
                            validateEndTime()
                        }
                        showingNumberPad = false
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: [.top, .bottom])
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: showingNumberPad)
    }
    
    // MARK: - Helper Functions
    
    /// Check if any audio effects are enabled
    private var hasEffectsEnabled: Bool {
        return audioEffects.fadeInDuration > 0 ||
               audioEffects.fadeOutDuration > 0 ||
               audioEffects.volumeBoost != 1.0 ||
               audioEffects.normalizeAudio ||
               audioEffects.reverbEnabled ||
               audioEffects.echoEnabled ||
               audioEffects.equalizerPreset != .none
    }
    
    private func requestMediaLibraryAccess() {
        let status = MPMediaLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            showingMediaPicker = true
        case .notDetermined:
            MPMediaLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized {
                        showingMediaPicker = true
                    }
                }
            }
        default:
            alertTitle = "Permission Required"
            alertMessage = "Please enable media library access in Settings"
            showingAlert = true
        }
    }
    
    private func loadAudioAsset(from url: URL) {
        Task {
            let asset = AVAsset(url: url)
            
            do {
                let duration = try await asset.load(.duration)
                let durationSeconds = CMTimeGetSeconds(duration)
                
                await MainActor.run {
                    self.audioAsset = asset
                    self.audioDuration = durationSeconds
                    self.endTime = min(30, durationSeconds)
                    self.endTimeText = formatTimeForInput(self.endTime)
                    self.isAudioLoaded = true
                }
            } catch {
                await MainActor.run {
                    alertTitle = "Error"
                    alertMessage = "Failed to load audio file"
                    showingAlert = true
                }
            }
        }
    }
    
    private func validateStartTime() {
        startTime = parseTimeString(startTimeText)
        startTime = max(0, min(startTime, audioDuration - 1))
        startTimeText = formatTimeForInput(startTime)
        
        // Automatically set end time to start + 30 seconds (or song end, whichever is shorter)
        endTime = min(startTime + maxRingtoneDuration, audioDuration)
        endTimeText = formatTimeForInput(endTime)
    }
    
    private func validateEndTime() {
        endTime = parseTimeString(endTimeText)
        endTime = max(startTime + 0.5, min(endTime, audioDuration))
        endTimeText = formatTimeForInput(endTime)
    }
    
    private func parseTimeString(_ timeString: String) -> Double {
        let components = timeString.split(separator: ":")
        if components.count == 2,
           let minutes = Int(components[0]),
           let seconds = Int(components[1]) {
            return Double(minutes * 60 + seconds)
        } else if components.count == 1,
                  let seconds = Int(components[0]) {
            return Double(seconds)
        }
        return 0
    }
    
    private func formatTimeForInput(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    private func stopPreview() {
        audioPlayer?.stop()
        audioPlayer = nil
        avPlayer?.pause()
        avPlayer = nil
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
        currentPlaybackTime = 0
    }
    
    private func playPreview() {
        guard let url = selectedAudioURL else { return }
        
        stopPreview()
        
        // Try AVAudioPlayer first (for file-based audio)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            currentPlaybackTime = 0
            
            // Update progress every 0.1 seconds
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
                if let player = self.audioPlayer, player.isPlaying {
                    self.currentPlaybackTime = player.currentTime
                } else {
                    self.stopPreview()
                }
            }
        } catch {
            // If AVAudioPlayer fails, use AVPlayer (for Music Library files)
            print("AVAudioPlayer failed, trying AVPlayer: \(error)")
            
            guard let asset = audioAsset else { return }
            
            let playerItem = AVPlayerItem(asset: asset)
            avPlayer = AVPlayer(playerItem: playerItem)
            avPlayer?.play()
            isPlaying = true
            currentPlaybackTime = 0
            
            // Update progress every 0.1 seconds
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
                if let player = self.avPlayer, player.timeControlStatus == .playing || player.timeControlStatus == .paused {
                    let currentTime = CMTimeGetSeconds(player.currentTime())
                    if currentTime.isFinite {
                        self.currentPlaybackTime = currentTime
                    }
                    
                    // Check if finished
                    if let duration = player.currentItem?.duration {
                        let totalDuration = CMTimeGetSeconds(duration)
                        if currentTime >= totalDuration - 0.1 {
                            self.stopPreview()
                        }
                    }
                } else if self.avPlayer?.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                    // Still loading
                } else {
                    self.stopPreview()
                }
            }
        }
    }
    
    private func playSelectedPortion() {
        guard let asset = audioAsset else { return }
        
        stopPreview()
        
        Task {
            do {
                // Export the selected portion to a temp file
                let startCMTime = CMTime(seconds: startTime, preferredTimescale: 600)
                let endCMTime = CMTime(seconds: endTime, preferredTimescale: 600)
                let timeRange = CMTimeRange(start: startCMTime, end: endCMTime)
                
                guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
                    return
                }
                
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("preview_selection_\(Date().timeIntervalSince1970).m4a")
                
                exportSession.outputURL = tempURL
                exportSession.outputFileType = .m4a
                exportSession.timeRange = timeRange
                
                await exportSession.export()
                
                if exportSession.status == .completed {
                    await MainActor.run {
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: tempURL)
                            audioPlayer?.prepareToPlay()
                            audioPlayer?.play()
                            isPlaying = true
                            currentPlaybackTime = startTime
                            
                            // Update progress every 0.1 seconds
                            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
                                if let player = self.audioPlayer, player.isPlaying {
                                    // Map player time to actual song time
                                    let progress = player.currentTime / player.duration
                                    self.currentPlaybackTime = self.startTime + (progress * (self.endTime - self.startTime))
                                } else {
                                    self.stopPreview()
                                }
                            }
                        } catch {
                            print("Selection preview playback error: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    private func playPreviewWithEffects() {
        guard let asset = audioAsset else { return }
        guard purchaseManager.isPremium else { return }
        
        stopPreview()
        isPreviewingEffects = true
        
        Task {
            do {
                print("🎵 Starting preview with effects...")
                
                // Export with effects to temp file
                let tempURL = try await AudioProcessor.exportRingtoneWithEffects(
                    asset: asset,
                    startTime: startTime,
                    endTime: endTime,
                    effects: audioEffects
                )
                
                print("✅ Effects preview exported to: \(tempURL)")
                
                await MainActor.run {
                    isPreviewingEffects = false
                    
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: tempURL)
                        audioPlayer?.prepareToPlay()
                        audioPlayer?.play()
                        isPlaying = true
                        currentPlaybackTime = startTime
                        
                        // Update progress every 0.1 seconds
                        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
                            if let player = self.audioPlayer, player.isPlaying {
                                // Map player time to actual song time
                                let progress = player.currentTime / player.duration
                                self.currentPlaybackTime = self.startTime + (progress * (self.endTime - self.startTime))
                            } else {
                                self.stopPreview()
                                // Clean up temp file
                                try? FileManager.default.removeItem(at: tempURL)
                            }
                        }
                    } catch {
                        print("❌ Effects preview playback error: \(error)")
                    }
                }
            } catch {
                await MainActor.run {
                    isPreviewingEffects = false
                    alertTitle = "Preview Error"
                    alertMessage = "Failed to preview with effects: \(error.localizedDescription)"
                    showingAlert = true
                }
                print("❌ Effects preview error: \(error)")
            }
        }
    }
    
    private func seekToTime(_ time: Double) {
        if let player = audioPlayer {
            player.currentTime = time
            currentPlaybackTime = time
        } else if let player = avPlayer {
            let cmTime = CMTime(seconds: time, preferredTimescale: 600)
            player.seek(to: cmTime)
            currentPlaybackTime = time
        }
    }
    
    private func handleExport() {
        guard !purchaseManager.needsToWatchAdsOrUpgrade else {
            // Show purchase view where user can watch ads or upgrade
            showingPremiumView = true
            return
        }
        
        guard let asset = audioAsset else { return }
        
        isExporting = true
        
        Task {
            do {
                let url = try await exportRingtone(asset: asset)
                await MainActor.run {
                    exportedFileURL = url
                    isExporting = false
                    purchaseManager.useFreeCreation()
                }
            } catch {
                await MainActor.run {
                    isExporting = false
                    alertTitle = "Export Failed"
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
    
    private func exportRingtone(asset: AVAsset) async throws -> URL {
        // Use premium audio processor if premium and effects are enabled
        if purchaseManager.isPremium && (audioEffects.fadeInDuration > 0 || audioEffects.fadeOutDuration > 0 || audioEffects.volumeBoost != 1.0) {
            return try await AudioProcessor.exportRingtoneWithEffects(
                asset: asset,
                startTime: startTime,
                endTime: endTime,
                effects: audioEffects
            )
        }
        
        // Standard export (free users)
        let startCMTime = CMTime(seconds: startTime, preferredTimescale: 600)
        let endCMTime = CMTime(seconds: endTime, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: startCMTime, end: endCMTime)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw NSError(domain: "Export", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create export session"])
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentsPath.appendingPathComponent("Ringtone_\(Date().timeIntervalSince1970).m4r")
        
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        exportSession.timeRange = timeRange
        
        await exportSession.export()
        
        if exportSession.status == .completed {
            return outputURL
        } else {
            throw exportSession.error ?? NSError(domain: "Export", code: -1)
        }
    }
}

// MARK: - Media Picker

struct MediaPickerView: UIViewControllerRepresentable {
    @Binding var selectedSongTitle: String
    @Binding var selectedAudioURL: URL?
    var onSongSelected: (URL) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> MPMediaPickerController {
        let picker = MPMediaPickerController(mediaTypes: .music)
        picker.allowsPickingMultipleItems = false
        picker.showsCloudItems = false
        picker.delegate = context.coordinator
        
        // Apply dark theme to match app
        picker.view.tintColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1) // Green tint
        picker.overrideUserInterfaceStyle = .dark
        
        // Customize navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        appearance.titleTextAttributes = [.foregroundColor: UIColor(red: 0, green: 1, blue: 0, alpha: 1)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(red: 0, green: 1, blue: 0, alpha: 1)]
        
        picker.navigationController?.navigationBar.standardAppearance = appearance
        picker.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        picker.navigationController?.navigationBar.compactAppearance = appearance
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: MPMediaPickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MPMediaPickerControllerDelegate {
        let parent: MediaPickerView
        
        init(_ parent: MediaPickerView) {
            self.parent = parent
        }
        
        func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            if let item = mediaItemCollection.items.first,
               let assetURL = item.assetURL {
                let title = item.title ?? "Unknown"
                let artist = item.artist ?? "Unknown"
                parent.selectedSongTitle = "\(title) - \(artist)"
                parent.selectedAudioURL = assetURL
                parent.onSongSelected(assetURL)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Document Picker

struct DocumentPickerView: UIViewControllerRepresentable {
    @Binding var selectedSongTitle: String
    @Binding var selectedAudioURL: URL?
    var onFileSelected: (URL) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio, .mp3, .mpeg4Audio], asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        
        // Apply dark theme to match app
        picker.view.tintColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1) // Green tint
        picker.overrideUserInterfaceStyle = .dark
        
        // Customize navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        appearance.titleTextAttributes = [.foregroundColor: UIColor(red: 0, green: 1, blue: 0, alpha: 1)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(red: 0, green: 1, blue: 0, alpha: 1)]
        
        picker.navigationController?.navigationBar.standardAppearance = appearance
        picker.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        picker.navigationController?.navigationBar.compactAppearance = appearance
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView
        
        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.selectedSongTitle = url.lastPathComponent
            parent.selectedAudioURL = url
            parent.onFileSelected(url)
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView(purchaseManager: PurchaseManager())
}

// Preview showing the editor screen directly
#Preview("Editor Screen") {
    @Previewable @State var purchaseManager = PurchaseManager()
    @Previewable @State var showingSplash = false
    @Previewable @State var isAudioLoaded = true
    @Previewable @State var selectedSongTitle = "My Awesome Song.mp3"
    @Previewable @State var audioDuration: TimeInterval = 180.0
    @Previewable @State var startTime: Double = 0
    @Previewable @State var endTime: Double = 30
    @Previewable @State var startTimeText = "0:00"
    @Previewable @State var endTimeText = "0:30"
    
    ContentView(purchaseManager: purchaseManager)
        .onAppear {
            // This will show the editor screen in preview
        }
}
