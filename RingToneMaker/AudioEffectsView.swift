//
//  AudioEffectsView.swift
//  RingToneMaker
//
//  Premium audio effects controls
//

import SwiftUI

struct AudioEffectsView: View {
    @Binding var effects: AudioProcessor.AudioEffects
    @Binding var isExpanded: Bool
    let isPremium: Bool
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: "waveform.badge.magnifyingglass")
                        .foregroundColor(.green)
                    
                    Text("Audio Effects")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    if !isPremium {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.green.opacity(0.5))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.green.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
            }
            
            if isExpanded {
                if isPremium {
                    premiumEffectsContent
                } else {
                    lockedContent
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
    
    // MARK: - Premium Effects Content
    
    private var premiumEffectsContent: some View {
        VStack(spacing: 16) {
            // Fade In
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Fade In")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    Spacer()
                    Text("\(effects.fadeInDuration, specifier: "%.1f")s")
                        .font(.caption)
                        .foregroundColor(.green.opacity(0.7))
                }
                
                Slider(value: $effects.fadeInDuration, in: 0...3, step: 0.1)
                    .tint(.green)
            }
            
            // Fade Out
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Fade Out")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    Spacer()
                    Text("\(effects.fadeOutDuration, specifier: "%.1f")s")
                        .font(.caption)
                        .foregroundColor(.green.opacity(0.7))
                }
                
                Slider(value: $effects.fadeOutDuration, in: 0...3, step: 0.1)
                    .tint(.green)
            }
            
            Divider()
                .background(Color.green.opacity(0.3))
            
            // Volume Boost
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Volume Boost")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    Spacer()
                    Text("\(Int(effects.volumeBoost * 100))%")
                        .font(.caption)
                        .foregroundColor(.green.opacity(0.7))
                }
                
                Slider(value: $effects.volumeBoost, in: 0.5...2.0, step: 0.1)
                    .tint(.green)
                
                HStack {
                    Text("50%")
                        .font(.caption2)
                        .foregroundColor(.green.opacity(0.5))
                    Spacer()
                    Text("100%")
                        .font(.caption2)
                        .foregroundColor(.green.opacity(0.5))
                    Spacer()
                    Text("200%")
                        .font(.caption2)
                        .foregroundColor(.green.opacity(0.5))
                }
            }
            
            Divider()
                .background(Color.green.opacity(0.3))
            
            // Normalize Audio
            Toggle(isOn: $effects.normalizeAudio) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Normalize Audio")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    Text("Balance volume levels")
                        .font(.caption)
                        .foregroundColor(.green.opacity(0.6))
                }
            }
            .tint(.green)
            
            Divider()
                .background(Color.green.opacity(0.3))
            
            // Equalizer Preset
            VStack(alignment: .leading, spacing: 8) {
                Text("Equalizer")
                    .font(.subheadline)
                    .foregroundColor(.green)
                
                Picker("Equalizer", selection: $effects.equalizerPreset) {
                    ForEach(AudioProcessor.AudioEffects.EqualizerPreset.allCases, id: \.self) { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                .pickerStyle(.segmented)
                .colorMultiply(.green)
            }
            
            // Reset button
            Button(action: resetEffects) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset to Default")
                }
                .font(.caption)
                .foregroundColor(.green.opacity(0.7))
            }
        }
        .padding(16)
        .background(Color.green.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Locked Content
    
    private var lockedContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.title)
                .foregroundColor(.yellow)
            
            Text("Premium Feature")
                .font(.headline)
                .foregroundColor(.green)
            
            Text("Unlock professional audio effects")
                .font(.caption)
                .foregroundColor(.green.opacity(0.7))
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 6) {
                FeatureItem(icon: "waveform", text: "Fade In/Out")
                FeatureItem(icon: "speaker.wave.3", text: "Volume Boost")
                FeatureItem(icon: "slider.horizontal.3", text: "Equalizer Presets")
                FeatureItem(icon: "chart.bar", text: "Audio Normalization")
            }
            .padding(.vertical, 8)
            
            Button(action: onUpgrade) {
                HStack {
                    Image(systemName: "crown.fill")
                    Text("Upgrade to Premium")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .background(Color.green.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: - Helper Views
    
    private struct FeatureItem: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.green)
                    .frame(width: 20)
                Text(text)
                    .font(.caption)
                    .foregroundColor(.green.opacity(0.8))
            }
        }
    }
    
    // MARK: - Actions
    
    private func resetEffects() {
        effects = AudioProcessor.AudioEffects()
    }
}

#Preview {
    VStack {
        AudioEffectsView(
            effects: .constant(AudioProcessor.AudioEffects()),
            isExpanded: .constant(true),
            isPremium: true,
            onUpgrade: {}
        )
        .padding()
        
        AudioEffectsView(
            effects: .constant(AudioProcessor.AudioEffects()),
            isExpanded: .constant(true),
            isPremium: false,
            onUpgrade: {}
        )
        .padding()
    }
    .background(Color.black)
}
