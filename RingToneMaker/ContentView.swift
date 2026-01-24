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
    @State private var showingSaveDialog = false
    @State private var ringtoneName = ""
    @State private var isPreviewingEffects = false
    
    private let maxRingtoneDuration: Double = 30
    
    var body: some View {
        ZStack {
            if showingSplash {
                SplashScreenView(onComplete: {
                    showingSplash = false
                })
            } else {
                mainContent
            }
        }
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
        .sheet(isPresented: $showingPremiumView) {
            PurchaseView(purchaseManager: purchaseManager)
        }
        .sheet(isPresented: $showingLibrary) {
            RingtoneLibraryView(
                library: ringtoneLibrary,
                isPremium: purchaseManager.isPremium,
                onUpgrade: { showingPremiumView = true }
            )
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
    }
    
    // MARK: - Selection Screen
    
    private var selectionScreen: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.03) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "waveform.circle.fill")
                                .font(.system(size: min(70, geometry.size.width * 0.18)))
                                .foregroundColor(.green)
                                .shadow(color: .green.opacity(0.5), radius: 20)
                            
                            Text("ToneForge Studio")
                                .font(.system(size: min(32, geometry.size.width * 0.08), weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                            
                            Text("Your Phone, Your Ringtone")
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.green.opacity(0.15))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            
                            Text("Create custom ringtones")
                                .font(.subheadline)
                                .foregroundColor(.green.opacity(0.7))
                        }
                        .padding(.top, 8)  // Minimal top padding
                        
                        // Selection Buttons
                        VStack(spacing: 12) {
                            Button(action: { requestMediaLibraryAccess() }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "music.note.list")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                        .frame(width: 40)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("My Music Library")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                        Text("Choose a song to edit")
                                            .font(.caption)
                                            .foregroundColor(.green.opacity(0.6))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.green.opacity(0.5))
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                            }
                            
                            Button(action: { showingDocumentPicker = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "folder.fill")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                        .frame(width: 40)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Import Audio File")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                        Text("Browse your files")
                                            .font(.caption)
                                            .foregroundColor(.green.opacity(0.6))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.green.opacity(0.5))
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                        
                        // Premium Status
                        if !purchaseManager.isPremium {
                            VStack(spacing: 12) {
                                if purchaseManager.remainingFreeCreations > 0 {
                                    HStack {
                                        Image(systemName: "gift.fill")
                                            .foregroundColor(.green)
                                        Text("\(purchaseManager.remainingFreeCreations) Free Left")
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                        Spacer()
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
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
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(.horizontal, geometry.size.width * 0.05)
                        }
                        
                        // Library button (Premium feature)
                        Button(action: { showingLibrary = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "rectangle.stack.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                    .frame(width: 40)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text("My Ringtones")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                        if !purchaseManager.isPremium {
                                            Image(systemName: "crown.fill")
                                                .font(.caption)
                                                .foregroundColor(.yellow)
                                        }
                                        if ringtoneLibrary.ringtones.count > 0 {
                                            Text("(\(ringtoneLibrary.ringtones.count))")
                                                .font(.caption)
                                                .foregroundColor(.green.opacity(0.7))
                                        }
                                    }
                                    Text("View saved ringtones")
                                        .font(.caption)
                                        .foregroundColor(.green.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.green.opacity(0.5))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                        
                        Spacer(minLength: 20)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .ignoresSafeArea(edges: .top)  // Make selection screen ignore top safe area
        }
    }
    
    // MARK: - Editor Screen
    
    private var editorScreen: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Spacer()
                        
                        Text("Edit Ringtone")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 0)
                    .padding(.bottom, 2)
                    .background(Color.black)
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            // Song title
                            Text(selectedSongTitle)
                                .font(.subheadline)
                                .foregroundColor(.green.opacity(0.7))
                                .lineLimit(2)
                                .truncationMode(.middle)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            // Waveform (orange)
                            if let asset = audioAsset {
                                VStack(spacing: 8) {
                                    WaveformView(
                                        audioAsset: asset,
                                        startTime: startTime,
                                        endTime: endTime,
                                        totalDuration: audioDuration,
                                        isPlaying: isPlaying,
                                        audioPlayer: audioPlayer
                                    )
                                    .frame(height: min(120, geometry.size.height * 0.15))
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .background(Color.green.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    // Playback progress indicator
                                    PlaybackProgressView(
                                        currentTime: currentPlaybackTime,
                                        totalDuration: audioDuration,
                                        onSeek: { time in
                                            seekToTime(time)
                                        }
                                    )
                                    
                                    // Preview buttons
                                    VStack(spacing: 8) {
                                        HStack(spacing: 8) {
                                            // Preview full song
                                            Button(action: {
                                                if isPlaying {
                                                    stopPreview()
                                                } else {
                                                    playPreview()
                                                }
                                            }) {
                                                HStack(spacing: 6) {
                                                    Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                                        .font(.body)
                                                    Text(isPlaying ? "Stop" : "Full Song")
                                                        .font(.caption)
                                                }
                                                .foregroundColor(.green)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(Color.green.opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
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
                                                HStack(spacing: 6) {
                                                    Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                                        .font(.body)
                                                    Text(isPlaying ? "Stop" : "Selection")
                                                        .font(.caption)
                                                }
                                                .foregroundColor(.orange)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(Color.orange.opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                                )
                                            }
                                        }
                                        
                                        // Preview with effects (Premium only) - Always visible
                                        if purchaseManager.isPremium {
                                            Button(action: {
                                                if hasEffectsEnabled {
                                                    // Effects enabled: preview with effects
                                                    if isPlaying {
                                                        stopPreview()
                                                    } else {
                                                        playPreviewWithEffects()
                                                    }
                                                } else {
                                                    // No effects: scroll to and expand Audio Effects panel
                                                    withAnimation {
                                                        showingAudioEffects = true
                                                    }
                                                }
                                            }) {
                                                HStack(spacing: 6) {
                                                    if isPreviewingEffects {
                                                        ProgressView()
                                                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                                                            .scaleEffect(0.8)
                                                        Text("Processing...")
                                                            .font(.caption)
                                                    } else if hasEffectsEnabled {
                                                        Image(systemName: isPlaying ? "stop.circle.fill" : "waveform.circle.fill")
                                                            .font(.body)
                                                        Text(isPlaying ? "Stop" : "Preview with Effects")
                                                            .font(.caption)
                                                    } else {
                                                        Image(systemName: "wand.and.stars")
                                                            .font(.body)
                                                        Text("Apply Effects to Preview")
                                                            .font(.caption)
                                                    }
                                                }
                                                .foregroundColor(hasEffectsEnabled ? .purple : .purple.opacity(0.7))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(hasEffectsEnabled ? Color.purple.opacity(0.1) : Color.purple.opacity(0.05))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(hasEffectsEnabled ? Color.purple.opacity(0.3) : Color.purple.opacity(0.2), lineWidth: 1)
                                                )
                                            }
                                            .disabled(isPreviewingEffects)
                                        }
                                    }
                                }
                                .padding(.horizontal, geometry.size.width * 0.05)
                            }
                            
                            // Audio Effects (Premium feature)
                            AudioEffectsView(
                                effects: $audioEffects,
                                isExpanded: $showingAudioEffects,
                                isPremium: purchaseManager.isPremium,
                                onUpgrade: { showingPremiumView = true }
                            )
                            .padding(.horizontal, geometry.size.width * 0.05)
                            
                            // Time controls
                            VStack(spacing: 8) {
                                HStack(spacing: geometry.size.width * 0.1) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Start")
                                            .font(.caption2)
                                            .foregroundColor(.green.opacity(0.7))
                                        Text(startTimeText)
                                            .font(.callout)
                                            .foregroundColor(.primary)
                                            .frame(width: geometry.size.width * 0.18)
                                            .padding(.vertical, 6)
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
                                            .font(.callout)
                                            .foregroundColor(.primary)
                                            .frame(width: geometry.size.width * 0.18)
                                            .padding(.vertical, 6)
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
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal, geometry.size.width * 0.05)
                            
                            // Export button
                            Button(action: { handleExport() }) {
                                HStack {
                                    if isExporting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        Text("Creating...")
                                    } else {
                                        Image(systemName: "scissors")
                                        Text("Create Ringtone")
                                    }
                                }
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(isExporting || (endTime - startTime) > maxRingtoneDuration)
                            .padding(.horizontal, geometry.size.width * 0.05)
                            
                            // Back button - centered below Create Ringtone
                            Button(action: {
                                isAudioLoaded = false
                                selectedAudioURL = nil
                                audioAsset = nil
                                selectedSongTitle = "No song selected"
                                stopPreview()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "chevron.left")
                                    Text("Back to Selection")
                                }
                                .font(.callout)
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, geometry.size.width * 0.05)
                            
                            Spacer(minLength: 10)
                        }
                    }
                }
                
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
            .ignoresSafeArea(edges: .top)  // Make entire editor screen ignore top safe area
        }
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
            alertTitle = "Limit Reached"
            alertMessage = "Watch ads or upgrade to Premium"
            showingAlert = true
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
