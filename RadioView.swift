//
//  RadioView.swift
//  RingToneMaker
//
//  Internet radio streaming with clip recording for ringtones
//

import SwiftUI

struct RadioView: View {
    @Bindable var purchaseManager: PurchaseManager
    var playerManager: RadioPlayerManager
    let onUseClip: (URL) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var apiClient = RadioAPIClient()
    @State private var favoritesManager = RadioFavoritesManager()
    @State private var selectedGenre: RadioGenre = .popular
    @State private var searchText = ""
    @State private var isSearching = false
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Genre tabs
                    genreTabs
                    
                    // Search bar
                    searchBar
                    
                    // Station list
                    if apiClient.isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        Text("Loading stations...")
                            .font(.caption)
                            .foregroundColor(.green.opacity(0.6))
                        Spacer()
                    } else if let error = apiClient.errorMessage {
                        Spacer()
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.orange)
                        Button("Retry") {
                            Task { await apiClient.fetchStations(for: selectedGenre) }
                        }
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.top, 8)
                        Spacer()
                    } else {
                        stationList
                    }
                    
                    // Now playing bar
                    if playerManager.currentStation != nil {
                        nowPlayingBar
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Text("‹ Back")
                            .font(.body)
                            .foregroundColor(.green)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Radio")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
        }
        .preferredColorScheme(.dark)
        .task {
            await apiClient.fetchStations(for: .popular)
        }
        
    }
    
    // MARK: - Genre Tabs
    
    private var genreTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(RadioGenre.allCases) { genre in
                    Button(action: {
                        selectedGenre = genre
                        isSearching = false
                        searchText = ""
                        if genre == .favorites {
                            apiClient.stations = favoritesManager.favoriteStations
                        } else {
                            Task { await apiClient.fetchStations(for: genre) }
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: genre.icon)
                                .font(.caption2)
                            Text(genre.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(selectedGenre == genre && !isSearching ? .black : .green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(selectedGenre == genre && !isSearching ? Color.green : Color.green.opacity(0.1))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.green.opacity(0.3), lineWidth: selectedGenre == genre && !isSearching ? 0 : 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.green.opacity(0.5))
            
            TextField("Search stations...", text: $searchText)
                .font(.caption)
                .foregroundColor(.green)
                .onSubmit {
                    isSearching = true
                    Task { await apiClient.searchStations(query: searchText) }
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isSearching = false
                    Task { await apiClient.fetchStations(for: selectedGenre) }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.green.opacity(0.5))
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.green.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }
    
    // MARK: - Station List
    
    private var stationList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(apiClient.stations) { station in
                    stationRow(station)
                }
            }
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
        }
    }
    
    private func stationRow(_ station: RadioStation) -> some View {
        let isActive = playerManager.currentStation?.id == station.id
        
        return HStack(spacing: 0) {
            // Tappable station area
            Button(action: {
                if isActive {
                    playerManager.togglePlayPause()
                } else {
                    playerManager.play(station: station)
                }
            }) {
                HStack(spacing: 10) {
                    // Station icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(isActive ? 0.2 : 0.08))
                            .frame(width: 40, height: 40)
                        
                        if let faviconURL = station.faviconURL {
                            AsyncImage(url: faviconURL) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 28, height: 28)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            } placeholder: {
                                Image(systemName: "radio.fill")
                                    .foregroundColor(.green)
                            }
                        } else {
                            Image(systemName: "radio.fill")
                                .foregroundColor(.green)
                        }
                    }
                    
                    // Station info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(station.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(isActive ? .green : .green.opacity(0.9))
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            if !station.country.isEmpty {
                                Text(station.country)
                                    .font(.system(size: 10))
                                    .foregroundColor(.green.opacity(0.4))
                            }
                            if station.bitrate > 0 {
                                Text("•")
                                    .font(.system(size: 10))
                                    .foregroundColor(.green.opacity(0.3))
                                Text("\(station.bitrate)kbps")
                                    .font(.system(size: 10))
                                    .foregroundColor(.green.opacity(0.4))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Play indicator
                    if isActive {
                        if playerManager.isBuffering {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                                .scaleEffect(0.7)
                        } else if playerManager.isPlaying {
                            Image(systemName: "waveform")
                                .foregroundColor(.green)
                                .font(.caption)
                        } else {
                            Image(systemName: "pause.fill")
                                .foregroundColor(.green.opacity(0.5))
                                .font(.caption)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            
            // Favorite toggle
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    favoritesManager.toggle(station)
                    // If viewing favorites, refresh the list
                    if selectedGenre == .favorites {
                        apiClient.stations = favoritesManager.favoriteStations
                    }
                }
            }) {
                Image(systemName: favoritesManager.isFavorite(station) ? "star.fill" : "star")
                    .font(.body)
                    .foregroundColor(favoritesManager.isFavorite(station) ? .yellow : .green.opacity(0.3))
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isActive ? Color.green.opacity(0.08) : Color.clear)
        )
    }
    
    // MARK: - Now Playing Bar
    
    private var nowPlayingBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.green.opacity(0.2))
                .frame(height: 0.5)
            
            HStack(spacing: 12) {
                // Station info
                VStack(alignment: .leading, spacing: 2) {
                    Text(playerManager.currentStation?.displayName ?? "")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .lineLimit(1)
                    
                    if playerManager.isBuffering {
                        Text("Buffering...")
                            .font(.system(size: 10))
                            .foregroundColor(.green.opacity(0.5))
                    } else {
                        Text(playerManager.isPlaying ? "Playing" : "Paused")
                            .font(.system(size: 10))
                            .foregroundColor(.green.opacity(0.5))
                    }
                }
                
                Spacer()
                
                // Play/Pause
                Button(action: { playerManager.togglePlayPause() }) {
                    Image(systemName: playerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
                
                // Stop
                Button(action: { playerManager.stop() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green.opacity(0.5))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.black)
        }
        .frame(maxWidth: .infinity)
    }
    
}

#Preview {
    RadioView(purchaseManager: PurchaseManager(), playerManager: RadioPlayerManager()) { _ in }
}
