//
//  WaveformView.swift
//  RingToneMaker
//
//  Created on 1/18/26.
//

import SwiftUI
import AVFoundation

struct WaveformView: View {
    let audioAsset: AVAsset
    let startTime: Double
    let endTime: Double
    let totalDuration: Double
    let isPlaying: Bool
    let audioPlayer: AVAudioPlayer?
    
    @State private var waveformSamples: [Float] = []
    @State private var isLoading = true
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    @State private var animatedAmplitudes: [Float] = []
    @State private var animationTimer: Timer?
    
    private let sampleCount: Int = 100
    private let waveformHeight: CGFloat = 120
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 3.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isLoading {
                    // Show placeholder waveform immediately
                    HStack(alignment: .center, spacing: 2) {
                        ForEach(0..<sampleCount, id: \.self) { index in
                            WaveformBar(
                                amplitude: Float.random(in: 0.2...0.6),
                                maxHeight: waveformHeight,
                                isInSelection: isInSelectedRange(index: index, totalSamples: sampleCount),
                                isAnimating: false
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                    .opacity(0.3)
                    
                    // Loading indicator overlay - centered
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                            .scaleEffect(0.8)
                        Text("Loading...")
                            .font(.caption2)
                            .foregroundColor(.orange.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Waveform bars with zoom and pan
                    HStack(alignment: .center, spacing: 2) {
                        ForEach(0..<waveformSamples.count, id: \.self) { index in
                            WaveformBar(
                                amplitude: isPlaying && index < animatedAmplitudes.count ? animatedAmplitudes[index] : waveformSamples[index],
                                maxHeight: waveformHeight,
                                isInSelection: isInSelectedRange(index: index, totalSamples: waveformSamples.count),
                                isAnimating: isPlaying
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                    .transition(.opacity)
                    .animation(.easeIn(duration: 0.3), value: isLoading)
                    .scaleEffect(x: scale, y: 1.0, anchor: .center)
                    .offset(x: offset)
                    .animation(.easeInOut(duration: 0.2), value: startTime)
                    .animation(.easeInOut(duration: 0.2), value: endTime)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let newScale = lastScale * value
                                scale = min(max(newScale, minScale), maxScale)
                            }
                            .onEnded { _ in
                                lastScale = scale
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                let maxOffset = (geometry.size.width * (scale - 1)) / 2
                                let newOffset = lastOffset + value.translation.width
                                offset = min(max(newOffset, -maxOffset), maxOffset)
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                }
            }
            .frame(height: waveformHeight)
        }
        .frame(height: waveformHeight)
        .onAppear {
            loadWaveform()
        }
        .onChange(of: audioAsset) { _ in
            loadWaveform()
            // Reset zoom and pan
            scale = 1.0
            lastScale = 1.0
            offset = 0
            lastOffset = 0
        }
        .onChange(of: isPlaying) { newValue in
            if newValue {
                startEqualizerAnimation()
            } else {
                stopEqualizerAnimation()
            }
        }
    }
    
    private func isInSelectedRange(index: Int, totalSamples: Int) -> Bool {
        let timePerSample = totalDuration / Double(totalSamples)
        let sampleTime = Double(index) * timePerSample
        return sampleTime >= startTime && sampleTime <= endTime
    }
    
    private func startEqualizerAnimation() {
        // Initialize animated amplitudes with current waveform
        animatedAmplitudes = waveformSamples
        
        // Start animation timer
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            // Create bouncing effect by randomly varying amplitudes
            animatedAmplitudes = waveformSamples.map { baseAmplitude in
                let variation = Float.random(in: 0.7...1.3)
                return min(1.0, baseAmplitude * variation)
            }
        }
    }
    
    private func stopEqualizerAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        animatedAmplitudes = waveformSamples
    }
    
    private func loadWaveform() {
        isLoading = true
        
        Task {
            do {
                let samples = try await extractAudioSamples(from: audioAsset, sampleCount: sampleCount)
                await MainActor.run {
                    self.waveformSamples = samples
                    self.isLoading = false
                }
            } catch {
                print("Error loading waveform: \(error)")
                await MainActor.run {
                    self.waveformSamples = Array(repeating: 0.3, count: sampleCount)
                    self.isLoading = false
                }
            }
        }
    }
    
    private func extractAudioSamples(from asset: AVAsset, sampleCount: Int) async throws -> [Float] {
        guard let track = try await asset.loadTracks(withMediaType: .audio).first else {
            throw NSError(domain: "WaveformView", code: 1, userInfo: [NSLocalizedDescriptionKey: "No audio track found"])
        }
        
        let duration = try await asset.load(.duration)
        let totalSeconds = CMTimeGetSeconds(duration)
        
        // Read small time slices spread across the file
        // Each slice is ~0.1 seconds — total memory stays tiny
        let sliceDuration: Double = 0.1
        let sliceInterval = totalSeconds / Double(sampleCount)
        var samples: [Float] = []
        
        for i in 0..<sampleCount {
            let sliceStart = Double(i) * sliceInterval
            let sliceEnd = min(sliceStart + sliceDuration, totalSeconds)
            let timeRange = CMTimeRange(
                start: CMTime(seconds: sliceStart, preferredTimescale: 44100),
                end: CMTime(seconds: sliceEnd, preferredTimescale: 44100)
            )
            
            do {
                let reader = try AVAssetReader(asset: asset)
                let outputSettings: [String: Any] = [
                    AVFormatIDKey: kAudioFormatLinearPCM,
                    AVLinearPCMBitDepthKey: 16,
                    AVLinearPCMIsBigEndianKey: false,
                    AVLinearPCMIsFloatKey: false,
                    AVLinearPCMIsNonInterleaved: false
                ]
                
                let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
                reader.timeRange = timeRange
                reader.add(output)
                reader.startReading()
                
                var sliceSum: Float = 0
                var sliceCount: Int = 0
                
                while let sampleBuffer = output.copyNextSampleBuffer() {
                    guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { continue }
                    let length = CMBlockBufferGetDataLength(blockBuffer)
                    var data = Data(count: length)
                    
                    data.withUnsafeMutableBytes { bytes in
                        CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: bytes.baseAddress!)
                    }
                    
                    data.withUnsafeBytes { rawBuffer in
                        let count = length / MemoryLayout<Int16>.size
                        let ptr = rawBuffer.baseAddress!.assumingMemoryBound(to: Int16.self)
                        for j in 0..<count {
                            sliceSum += abs(Float(ptr[j]))
                            sliceCount += 1
                        }
                    }
                }
                
                reader.cancelReading()
                
                if sliceCount > 0 {
                    samples.append((sliceSum / Float(sliceCount)) / Float(Int16.max))
                } else {
                    samples.append(0)
                }
            } catch {
                samples.append(0)
            }
        }
        
        return samples
    }
}

struct WaveformBar: View {
    let amplitude: Float
    let maxHeight: CGFloat
    let isInSelection: Bool
    let isAnimating: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.orange)
            .frame(width: 3, height: max(2, CGFloat(amplitude) * maxHeight * 0.8))
            .animation(isAnimating ? .easeInOut(duration: 0.05) : .easeInOut(duration: 0.15), value: amplitude)
    }
}

#Preview {
    WaveformView(
        audioAsset: AVAsset(),
        startTime: 0,
        endTime: 30,
        totalDuration: 180,
        isPlaying: false,
        audioPlayer: nil
    )
    .padding()
}
