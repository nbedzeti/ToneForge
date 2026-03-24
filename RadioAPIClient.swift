//
//  RadioAPIClient.swift
//  RingToneMaker
//
//  Fetches stations from the Radio Browser API
//

import Foundation

@MainActor
@Observable
class RadioAPIClient {
    
    var stations: [RadioStation] = []
    var isLoading = false
    var errorMessage: String?
    
    private let baseURL = "https://de1.api.radio-browser.info/json"
    private var cache: [String: [RadioStation]] = [:]
    
    func fetchStations(for genre: RadioGenre) async {
        let cacheKey = genre.rawValue
        
        // Return cached if available
        if let cached = cache[cacheKey] {
            stations = cached
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let urlString: String
            if genre == .popular {
                urlString = "\(baseURL)/stations/topvote/50"
            } else {
                let tag = genre.searchTag.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? genre.searchTag
                urlString = "\(baseURL)/stations/bytag/\(tag)?limit=50&order=votes&reverse=true&hidebroken=true"
            }
            
            guard let url = URL(string: urlString) else {
                errorMessage = "Invalid URL"
                isLoading = false
                return
            }
            
            var request = URLRequest(url: url)
            request.setValue("ToneForgeStudio/1.0", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 10
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode([RadioStation].self, from: data)
            
            // Filter out stations without valid stream URLs
            let valid = decoded.filter { $0.streamURL != nil && !$0.name.isEmpty }
            
            cache[cacheKey] = valid
            stations = valid
        } catch {
            errorMessage = "Failed to load stations"
            print("❌ Radio API error: \(error)")
        }
        
        isLoading = false
    }
    
    func searchStations(query: String) async {
        guard !query.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            let urlString = "\(baseURL)/stations/byname/\(encoded)?limit=30&order=votes&reverse=true&hidebroken=true"
            
            guard let url = URL(string: urlString) else {
                errorMessage = "Invalid search"
                isLoading = false
                return
            }
            
            var request = URLRequest(url: url)
            request.setValue("ToneForgeStudio/1.0", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 10
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode([RadioStation].self, from: data)
            
            stations = decoded.filter { $0.streamURL != nil && !$0.name.isEmpty }
        } catch {
            errorMessage = "Search failed"
        }
        
        isLoading = false
    }
}
