//
//  PlaybackProgressView.swift
//  RingToneMaker
//
//  Playback progress indicator with timeline
//

import SwiftUI

struct PlaybackProgressView: View {
    let currentTime: Double
    let totalDuration: Double
    let onSeek: (Double) -> Void
    
    @State private var isDragging = false
    @State private var dragPosition: Double = 0
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress bar with moving indicator
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background line (full song length)
                    Rectangle()
                        .fill(Color.green.opacity(0.3))
                        .frame(height: 2)
                    
                    // Vertical moving indicator
                    let displayTime = isDragging ? dragPosition : currentTime
                    let progress = totalDuration > 0 ? CGFloat(displayTime / totalDuration) : 0
                    let xPosition = progress * geometry.size.width
                    
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 2, height: 20)
                        .offset(x: xPosition - 1)
                        .animation(isDragging ? .none : .linear(duration: 0.1), value: currentTime)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            let progress = max(0, min(1, value.location.x / geometry.size.width))
                            dragPosition = progress * totalDuration
                        }
                        .onEnded { value in
                            let progress = max(0, min(1, value.location.x / geometry.size.width))
                            let seekTime = progress * totalDuration
                            onSeek(seekTime)
                            isDragging = false
                        }
                )
            }
            .frame(height: 20)
            
            // Time labels
            HStack {
                // Start time (0:00)
                Text("0:00")
                    .font(.caption2)
                    .foregroundColor(.green.opacity(0.7))
                    .frame(width: 40, alignment: .leading)
                
                Spacer()
                
                // Current time (center, moving)
                Text(formatTime(isDragging ? dragPosition : currentTime))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Spacer()
                
                // Total duration (end)
                Text(formatTime(totalDuration))
                    .font(.caption2)
                    .foregroundColor(.green.opacity(0.7))
                    .frame(width: 40, alignment: .trailing)
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    PlaybackProgressView(currentTime: 83, totalDuration: 245, onSeek: { _ in })
        .padding()
        .background(Color.black)
}
