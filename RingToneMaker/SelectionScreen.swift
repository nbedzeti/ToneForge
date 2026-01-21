//
//  SelectionScreen.swift
//  RingToneMaker
//
//  Screen 1: File Selection
//

import SwiftUI

struct SelectionScreen: View {
    @Bindable var purchaseManager: PurchaseManager
    @Binding var selectedSongTitle: String
    @Binding var showingMediaPicker: Bool
    @Binding var showingDocumentPicker: Bool
    @Binding var showingPremiumView: Bool
    let requestMediaLibraryAccess: () -> Void
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "waveform.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.green)
                            .shadow(color: .green.opacity(0.5), radius: 20)
                        
                        Text("RingTone Maker")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                        
                        Text("Create custom ringtones in seconds")
                            .font(.subheadline)
                            .foregroundColor(.green.opacity(0.7))
                    }
                    .padding(.top, 40)
                    
                    // Selection Cards
                    VStack(spacing: 16) {
                        // Music Library Button
                        Button(action: {
                            requestMediaLibraryAccess()
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "music.note.list")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                    .frame(width: 50)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Music Library")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                    Text("Select from your songs")
                                        .font(.caption)
                                        .foregroundColor(.green.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.green.opacity(0.5))
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Browse Files Button
                        Button(action: {
                            showingDocumentPicker = true
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "folder.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                    .frame(width: 50)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Browse Files")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                    Text("Import audio files")
                                        .font(.caption)
                                        .foregroundColor(.green.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.green.opacity(0.5))
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Premium Status
                    if !purchaseManager.isPremium {
                        VStack(spacing: 12) {
                            if purchaseManager.remainingFreeCreations > 0 {
                                HStack {
                                    Image(systemName: "gift.fill")
                                        .foregroundColor(.green)
                                    Text("\(purchaseManager.remainingFreeCreations) Free Ringtones Left")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            Button(action: {
                                showingPremiumView = true
                            }) {
                                HStack {
                                    Image(systemName: "star.fill")
                                    Text("Upgrade to Premium")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // How It Works
                    VStack(spacing: 16) {
                        Text("How It Works")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        VStack(spacing: 12) {
                            StepView(number: "1", text: "Select your audio file")
                            StepView(number: "2", text: "Trim to 30 seconds")
                            StepView(number: "3", text: "Export as ringtone")
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StepView: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.headline)
                .foregroundColor(.black)
                .frame(width: 30, height: 30)
                .background(Color.green)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.green)
            
            Spacer()
        }
    }
}
