//
//  RingtoneLibraryView.swift
//  RingToneMaker
//
//  Premium feature: View and manage saved ringtones
//

import SwiftUI

struct RingtoneLibraryView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var library: RingtoneLibrary
    let isPremium: Bool
    let onUpgrade: () -> Void
    
    @State private var selectedFilter: FilterOption = .all
    @State private var searchText = ""
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case recent = "Recent"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isPremium {
                    premiumContent
                } else {
                    lockedContent
                }
            }
            .navigationTitle("Ringtone Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.green)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Premium Content
    
    private var premiumContent: some View {
        VStack(spacing: 0) {
            // Stats header
            HStack(spacing: 20) {
                StatItem(
                    icon: "music.note",
                    value: "\(library.ringtones.count)",
                    label: "Ringtones"
                )
                
                StatItem(
                    icon: "heart.fill",
                    value: "\(library.favoriteRingtones.count)",
                    label: "Favorites"
                )
                
                StatItem(
                    icon: "externaldrive",
                    value: library.formattedLibrarySize,
                    label: "Storage"
                )
            }
            .padding()
            .background(Color.green.opacity(0.1))
            
            // Filter picker
            Picker("Filter", selection: $selectedFilter) {
                ForEach(FilterOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .colorMultiply(.green)
            .padding()
            
            // Ringtones list
            if filteredRingtones.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredRingtones) { ringtone in
                            RingtoneRow(
                                ringtone: ringtone,
                                onToggleFavorite: {
                                    library.toggleFavorite(ringtone)
                                },
                                onShare: {
                                    print("📤 Sharing ringtone: \(ringtone.name)")
                                    print("📂 File URL: \(ringtone.fileURL)")
                                    
                                    // Use UIActivityViewController directly
                                    let activityVC = UIActivityViewController(
                                        activityItems: [ringtone.fileURL],
                                        applicationActivities: nil
                                    )
                                    
                                    // Get the root view controller
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let rootVC = windowScene.windows.first?.rootViewController {
                                        
                                        // Find the topmost presented view controller
                                        var topVC = rootVC
                                        while let presented = topVC.presentedViewController {
                                            topVC = presented
                                        }
                                        
                                        // For iPad: set popover presentation
                                        if let popover = activityVC.popoverPresentationController {
                                            popover.sourceView = topVC.view
                                            popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                                            popover.permittedArrowDirections = []
                                        }
                                        
                                        topVC.present(activityVC, animated: true)
                                    }
                                },
                                onDelete: {
                                    library.deleteRingtone(ringtone)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Locked Content
    
    private var lockedContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.rectangle.stack.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Premium Feature")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text("Save and organize your ringtones")
                .font(.subheadline)
                .foregroundColor(.green.opacity(0.7))
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 12) {
                LibraryFeatureRow(icon: "infinity", title: "Unlimited Storage", description: "Save as many ringtones as you want")
                LibraryFeatureRow(icon: "folder.fill", title: "Organize with Tags", description: "Keep your ringtones organized")
                LibraryFeatureRow(icon: "heart.fill", title: "Mark Favorites", description: "Quick access to your best ringtones")
                LibraryFeatureRow(icon: "square.and.arrow.up", title: "Batch Export", description: "Share multiple ringtones at once")
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal)
            
            Button(action: onUpgrade) {
                HStack {
                    Image(systemName: "crown.fill")
                    Text("Upgrade to Premium")
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 50))
                .foregroundColor(.green.opacity(0.5))
            
            Text("No Ringtones Yet")
                .font(.headline)
                .foregroundColor(.green)
            
            Text("Create ringtones and save them to your library")
                .font(.caption)
                .foregroundColor(.green.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Filtered Ringtones
    
    private var filteredRingtones: [RingtoneLibrary.SavedRingtone] {
        let ringtones: [RingtoneLibrary.SavedRingtone]
        
        switch selectedFilter {
        case .all:
            ringtones = library.ringtones
        case .favorites:
            ringtones = library.favoriteRingtones
        case .recent:
            ringtones = library.recentRingtones
        }
        
        if searchText.isEmpty {
            return ringtones
        } else {
            return ringtones.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.green)
            Text(value)
                .font(.headline)
                .foregroundColor(.green)
            Text(label)
                .font(.caption2)
                .foregroundColor(.green.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

struct RingtoneRow: View {
    let ringtone: RingtoneLibrary.SavedRingtone
    let onToggleFavorite: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: "music.note")
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 40, height: 40)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(ringtone.name)
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .lineLimit(1)
                    
                    // Show file format badge
                    Text("M4R")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
                
                HStack(spacing: 8) {
                    Text(ringtone.createdDate, style: .date)
                        .font(.caption2)
                        .foregroundColor(.green.opacity(0.6))
                    
                    if !ringtone.tags.isEmpty {
                        ForEach(ringtone.tags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .foregroundColor(.green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 16) {
                Button(action: onToggleFavorite) {
                    Image(systemName: ringtone.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(ringtone.isFavorite ? .red : .green.opacity(0.5))
                }
                
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.green.opacity(0.5))
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.7))
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }
}

struct LibraryFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.green.opacity(0.7))
            }
            
            Spacer()
        }
    }
}

#Preview {
    RingtoneLibraryView(
        library: RingtoneLibrary(),
        isPremium: true,
        onUpgrade: {}
    )
}
