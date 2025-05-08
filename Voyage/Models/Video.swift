//
//  Video.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import Foundation
import SwiftUI

struct Video: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var source: VideoSource
    var url: URL
    var thumbnailData: Data?
    var dateAdded: Date = Date()
    var tags: [String] = []
    var isFavorite: Bool = false
    var location: Location?
    var tripIDs: [UUID] = [] // The trips this video is associated with
    
    // Computed property for thumbnail image
    var thumbnail: Image? {
        guard let thumbnailData = thumbnailData,
              let uiImage = UIImage(data: thumbnailData) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
    
    // Location information
    struct Location: Codable, Hashable {
        var city: String
        var country: String
        var coordinates: Coordinates?
        
        struct Coordinates: Codable, Hashable {
            var latitude: Double
            var longitude: Double
        }
    }
    
    // For Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Video, rhs: Video) -> Bool {
        lhs.id == rhs.id
    }
    
    // Sample data
    static var samples: [Video] {
        [
            Video(
                title: "Tokyo Street Food Tour",
                source: .youtube,
                url: URL(string: "https://youtube.com/watch?v=sample1")!,
                tags: ["Food", "Tokyo", "Japan"],
                location: Location(city: "Tokyo", country: "Japan")
            ),
            Video(
                title: "Paris Cafe Morning",
                source: .instagram,
                url: URL(string: "https://instagram.com/p/sample2")!,
                tags: ["Cafe", "Paris", "France"],
                isFavorite: true,
                location: Location(city: "Paris", country: "France")
            ),
            Video(
                title: "Bali Beach Sunset",
                source: .tiktok,
                url: URL(string: "https://tiktok.com/@user/video/sample3")!,
                tags: ["Beach", "Sunset", "Bali", "Indonesia"],
                location: Location(city: "Bali", country: "Indonesia")
            ),
            Video(
                title: "Rome Walking Tour",
                source: .youtube,
                url: URL(string: "https://youtube.com/watch?v=sample4")!,
                tags: ["Walking", "Rome", "Italy"],
                location: Location(city: "Rome", country: "Italy")
            ),
            Video(
                title: "New York City Nightlife",
                source: .instagram,
                url: URL(string: "https://instagram.com/p/sample5")!,
                tags: ["Nightlife", "NYC", "USA"],
                location: Location(city: "New York", country: "United States")
            )
        ]
    }
    
    // All unique tags for filter options
    static var allTags: [String] {
        let allVideos = samples
        var tags = Set<String>()
        
        for video in allVideos {
            tags.formUnion(video.tags)
            if let location = video.location {
                tags.insert(location.city)
                tags.insert(location.country)
            }
            tags.insert(video.source.rawValue)
        }
        
        return Array(tags).sorted()
    }
    
    // Popular filters for the filter row
    static var popularFilters: [String] {
        ["Food", "Beach", "City", "Japan", "France", "Instagram", "YouTube", "TikTok"]
    }
}

enum VideoSource: String, Codable, CaseIterable {
    case instagram = "Instagram"
    case tiktok = "TikTok"
    case youtube = "YouTube"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .instagram:
            return "camera"
        case .tiktok:
            return "music.note"
        case .youtube:
            return "play.rectangle"
        case .other:
            return "film"
        }
    }
}
