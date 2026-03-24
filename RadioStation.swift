//
//  RadioStation.swift
//  RingToneMaker
//
//  Radio station model and Radio Browser API client
//

import Foundation

struct RadioStation: Identifiable, Codable, Hashable {
    var id: String { stationuuid }
    let stationuuid: String
    let name: String
    let url: String
    let url_resolved: String
    let favicon: String
    let tags: String
    let country: String
    let language: String
    let codec: String
    let bitrate: Int
    
    var displayName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var streamURL: URL? {
        URL(string: url_resolved.isEmpty ? url : url_resolved)
    }
    
    var faviconURL: URL? {
        guard !favicon.isEmpty else { return nil }
        return URL(string: favicon)
    }
}

enum RadioGenre: String, CaseIterable, Identifiable {
    case favorites = "Favorites"
    case popular = "Popular"
    case pop = "Pop"
    case rock = "Rock"
    case hiphop = "Hip-Hop"
    case jazz = "Jazz"
    case classical = "Classical"
    case electronic = "Electronic"
    case lofi = "Lo-Fi"
    case rnb = "R&B"
    case country = "Country"
    case latin = "Latin"
    case reggae = "Reggae"
    
    var id: String { rawValue }
    
    var searchTag: String {
        switch self {
        case .favorites: return ""
        case .popular: return ""
        case .pop: return "pop"
        case .rock: return "rock"
        case .hiphop: return "hip hop"
        case .jazz: return "jazz"
        case .classical: return "classical"
        case .electronic: return "electronic"
        case .lofi: return "lofi"
        case .rnb: return "rnb"
        case .country: return "country"
        case .latin: return "latin"
        case .reggae: return "reggae"
        }
    }
    
    var icon: String {
        switch self {
        case .favorites: return "heart.fill"
        case .popular: return "star.fill"
        case .pop: return "music.mic"
        case .rock: return "guitars.fill"
        case .hiphop: return "headphones"
        case .jazz: return "music.quarternote.3"
        case .classical: return "music.note"
        case .electronic: return "waveform"
        case .lofi: return "cloud.fill"
        case .rnb: return "heart.fill"
        case .country: return "leaf.fill"
        case .latin: return "flame.fill"
        case .reggae: return "sun.max.fill"
        }
    }
}

// MARK: - Favorites Manager

@MainActor
@Observable
class RadioFavoritesManager {
    var favoriteIDs: Set<String> = []
    var favoriteStations: [RadioStation] = []
    
    private let favoritesKey = "radioFavoriteStations"
    private let favoriteIDsKey = "radioFavoriteIDs"
    
    init() {
        // Load favorite IDs
        if let ids = UserDefaults.standard.array(forKey: favoriteIDsKey) as? [String] {
            favoriteIDs = Set(ids)
        }
        // Load favorite stations
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let stations = try? JSONDecoder().decode([RadioStation].self, from: data) {
            favoriteStations = stations
        }
    }
    
    func isFavorite(_ station: RadioStation) -> Bool {
        favoriteIDs.contains(station.id)
    }
    
    func toggle(_ station: RadioStation) {
        if isFavorite(station) {
            favoriteIDs.remove(station.id)
            favoriteStations.removeAll { $0.id == station.id }
        } else {
            favoriteIDs.insert(station.id)
            favoriteStations.append(station)
        }
        save()
    }
    
    private func save() {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: favoriteIDsKey)
        if let data = try? JSONEncoder().encode(favoriteStations) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
}
