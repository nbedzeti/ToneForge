//
//  SplashScreenView.swift
//  RingToneMaker
//
//  Animated splash screen on app launch
//

import SwiftUI

struct SplashScreenView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var glowIntensity: Double = 0
    
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Animated waveform icon
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .shadow(color: .green.opacity(glowIntensity), radius: 40)
                
                // App name
                Text("ToneForge")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                    .opacity(opacity)
            }
        }
        .onAppear {
            // Animate icon scale and opacity
            withAnimation(.easeOut(duration: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Pulse glow effect
            withAnimation(.easeInOut(duration: 1.0).repeatCount(2, autoreverses: true)) {
                glowIntensity = 0.8
            }
            
            // Dismiss splash screen after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(onComplete: {})
}
