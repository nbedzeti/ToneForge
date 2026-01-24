//
//  RingtoneLibrary.swift
//  RingToneMaker
//
//  Premium feature: Save and organize ringtones
//

import Foundation
import SwiftUI

/// Manages saved ringtones library (Premium feature)
@MainActor
@Observable
class RingtoneLibrary {
    
    // MARK: - Ringtone Model
    
    struct SavedRingtone: Identifiable, Codable {
        let id: UUID
        let name: String
        let fileURL: URL
        let createdDate: Date
        var tags: [String]
        var isFavorite: Bool
        
        init(name: String, fileURL: URL, tags: [String] = [], isFavorite: Bool = false) {
            self.id = UUID()
            self.name = name
            self.fileURL = fileURL
            self.createdDate = Date()
            self.tags = tags
            self.isFavorite = isFavorite
        }
    }
    
    // MARK: - Properties
    
    var ringtones: [SavedRingtone] = []
    var tags: Set<String> = []
    
    private let userDefaultsKey = "savedRingtones"
    private let libraryDirectory: URL
    
    // MARK: - Initialization
    
    init() {
        // Create library directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        libraryDirectory = documentsPath.appendingPathComponent("RingtoneLibrary", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: libraryDirectory, withIntermediateDirectories: true)
        
        loadRingtones()
    }
    
    // MARK: - Library Management
    
    /// Save a ringtone to the library
    func saveRingtone(from sourceURL: URL, name: String, tags: [String] = []) throws {
        // Copy file to library directory
        let fileName = "\(UUID().uuidString).m4r"
        let destinationURL = libraryDirectory.appendingPathComponent(fileName)
        
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        
        // Create ringtone entry
        let ringtone = SavedRingtone(name: name, fileURL: destinationURL, tags: tags)
        ringtones.append(ringtone)
        
        // Update tags
        tags.forEach { self.tags.insert($0) }
        
        saveRingtones()
    }
    
    /// Delete a ringtone from the library
    func deleteRingtone(_ ringtone: SavedRingtone) {
        // Remove file
        try? FileManager.default.removeItem(at: ringtone.fileURL)
        
        // Remove from array
        ringtones.removeAll { $0.id == ringtone.id }
        
        saveRingtones()
    }
    
    /// Toggle favorite status
    func toggleFavorite(_ ringtone: SavedRingtone) {
        if let index = ringtones.firstIndex(where: { $0.id == ringtone.id }) {
            ringtones[index].isFavorite.toggle()
            saveRingtones()
        }
    }
    
    /// Add tag to ringtone
    func addTag(_ tag: String, to ringtone: SavedRingtone) {
        if let index = ringtones.firstIndex(where: { $0.id == ringtone.id }) {
            if !ringtones[index].tags.contains(tag) {
                ringtones[index].tags.append(tag)
                tags.insert(tag)
                saveRingtones()
            }
        }
    }
    
    /// Remove tag from ringtone
    func removeTag(_ tag: String, from ringtone: SavedRingtone) {
        if let index = ringtones.firstIndex(where: { $0.id == ringtone.id }) {
            ringtones[index].tags.removeAll { $0 == tag }
            saveRingtones()
        }
    }
    
    // MARK: - Filtering
    
    /// Get ringtones filtered by tag
    func ringtones(withTag tag: String) -> [SavedRingtone] {
        return ringtones.filter { $0.tags.contains(tag) }
    }
    
    /// Get favorite ringtones
    var favoriteRingtones: [SavedRingtone] {
        return ringtones.filter { $0.isFavorite }
    }
    
    /// Get recent ringtones (last 10)
    var recentRingtones: [SavedRingtone] {
        return Array(ringtones.sorted { $0.createdDate > $1.createdDate }.prefix(10))
    }
    
    // MARK: - Persistence
    
    private func saveRingtones() {
        if let encoded = try? JSONEncoder().encode(ringtones) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadRingtones() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([SavedRingtone].self, from: data) {
            ringtones = decoded
            
            // Rebuild tags set
            tags = Set(ringtones.flatMap { $0.tags })
        }
    }
    
    // MARK: - Batch Operations
    
    /// Export multiple ringtones
    func exportRingtones(_ ringtones: [SavedRingtone]) -> [URL] {
        return ringtones.map { $0.fileURL }
    }
    
    /// Get total library size
    var totalLibrarySize: Int64 {
        var totalSize: Int64 = 0
        for ringtone in ringtones {
            if let attributes = try? FileManager.default.attributesOfItem(atPath: ringtone.fileURL.path),
               let fileSize = attributes[.size] as? Int64 {
                totalSize += fileSize
            }
        }
        return totalSize
    }
    
    /// Format library size for display
    var formattedLibrarySize: String {
        let size = totalLibrarySize
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}
