//
//  Idea.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import Foundation

struct Idea: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let tag: String
    let imageURL: String
    let dateAdded: Date = Date()
    
    // New properties
    let city: String
    let country: String
    let activityType: String
    let source: String
    var boardIDs: [UUID] = [] // The boards this idea belongs to
    var tripIDs: [UUID] = [] // The trips this idea belongs to
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Idea, rhs: Idea) -> Bool {
        lhs.id == rhs.id
    }
    
    // Trip-related computed properties
    var tripCount: Int {
        return tripIDs.count
    }
    
    // Create ideas for a specific board (used by BoardStore)
    static func ideasForBoard(boardID: UUID, count: Int, theme: String) -> [Idea] {
        var ideas: [Idea] = []
        
        // Choose a theme-appropriate activity type and country
        let (activityType, country) = themeDetails(for: theme)
        
        // Generate city options based on country
        let cities = citiesFor(country: country)
        
        // Sources to rotate through
        let sources = ["Instagram", "TikTok", "YouTube", "Friend", "Blog", "Pinterest"]
        
        // Create the requested number of ideas
        for i in 0..<count {
            let city = cities[i % cities.count]
            let source = sources[i % sources.count]
            let imageIndex = 100 + i
            
            ideas.append(
                Idea(title: "\(theme) Idea \(i+1)", 
                     tag: activityType,
                     imageURL: "https://picsum.photos/300/200?random=\(imageIndex)",
                     city: city,
                     country: country,
                     activityType: activityType,
                     source: source,
                     boardIDs: [boardID])
            )
        }
        
        return ideas
    }
    
    // Helper to get theme-appropriate activity type and country
    private static func themeDetails(for theme: String) -> (String, String) {
        switch theme.lowercased() {
        case let t where t.contains("japan"):
            return ("Culture", "Japan")
        case let t where t.contains("europe"):
            return ("Adventure", "France")
        case let t where t.contains("weekend"):
            return ("Relax", "Italy")
        case let t where t.contains("mornington"):
            return ("Nature", "Australia")
        default:
            return ("Food", "Thailand")
        }
    }
    
    // Helper to get cities based on country
    private static func citiesFor(country: String) -> [String] {
        switch country {
        case "Japan":
            return ["Tokyo", "Kyoto", "Osaka", "Hiroshima", "Nara"]
        case "France":
            return ["Paris", "Nice", "Lyon", "Marseille", "Bordeaux"]
        case "Italy":
            return ["Rome", "Venice", "Florence", "Milan", "Naples"]
        case "Australia":
            return ["Melbourne", "Sydney", "Perth", "Brisbane", "Adelaide"]
        case "Thailand":
            return ["Bangkok", "Chiang Mai", "Phuket", "Krabi", "Pattaya"]
        default:
            return ["City 1", "City 2", "City 3", "City 4", "City 5"]
        }
    }
    
    // Sample data
    static var samples: [Idea] {
        [
            Idea(title: "Paris Cafe", tag: "Food", imageURL: "https://picsum.photos/300/200?random=1", 
                 city: "Paris", country: "France", activityType: "Food", source: "Instagram",
                 tripIDs: [UUID()]), // Using placeholder UUIDs for demo purposes
            
            Idea(title: "Tokyo Street", tag: "Urban", imageURL: "https://picsum.photos/300/200?random=2",
                 city: "Tokyo", country: "Japan", activityType: "Urban", source: "TikTok",
                 boardIDs: [UUID()]),
            
            Idea(title: "Mountain Hike", tag: "Adventure", imageURL: "https://picsum.photos/300/200?random=3",
                 city: "Interlaken", country: "Switzerland", activityType: "Adventure", source: "YouTube",
                 tripIDs: [UUID(), UUID()]),
            
            Idea(title: "Beach Sunset", tag: "Relax", imageURL: "https://picsum.photos/300/200?random=4",
                 city: "Bali", country: "Indonesia", activityType: "Relax", source: "Friend"),
            
            Idea(title: "Italian Villa", tag: "Accommodation", imageURL: "https://picsum.photos/300/200?random=5",
                 city: "Tuscany", country: "Italy", activityType: "Accommodation", source: "Blog",
                 boardIDs: [UUID()]),
            
            Idea(title: "Traditional Cuisine", tag: "Food", imageURL: "https://picsum.photos/300/200?random=6",
                 city: "Bangkok", country: "Thailand", activityType: "Food", source: "Reddit",
                 tripIDs: [UUID()]),
            
            Idea(title: "Hidden Waterfall", tag: "Nature", imageURL: "https://picsum.photos/300/200?random=7",
                 city: "Ubud", country: "Indonesia", activityType: "Nature", source: "Pinterest",
                 boardIDs: [UUID(), UUID()]),
            
            Idea(title: "Local Market", tag: "Culture", imageURL: "https://picsum.photos/300/200?random=8",
                 city: "Marrakech", country: "Morocco", activityType: "Culture", source: "Instagram",
                 tripIDs: [UUID()])
        ]
    }
    
    static var unorganized: [Idea] {
        [
            Idea(title: "Scenic Route", tag: "Road Trip", imageURL: "https://picsum.photos/300/200?random=9",
                 city: "Amalfi Coast", country: "Italy", activityType: "Road Trip", source: "Magazine"),
            
            Idea(title: "Historic Museum", tag: "Culture", imageURL: "https://picsum.photos/300/200?random=10",
                 city: "London", country: "UK", activityType: "Culture", source: "Website"),
            
            Idea(title: "Street Food", tag: "Food", imageURL: "https://picsum.photos/300/200?random=11",
                 city: "Hanoi", country: "Vietnam", activityType: "Food", source: "TikTok")
        ]
    }
    
    // All unique tags for filter options
    static var allTags: [String] {
        let allIdeas = samples + unorganized
        var tags = Set<String>()
        
        for idea in allIdeas {
            tags.insert(idea.tag)
            tags.insert(idea.city)
            tags.insert(idea.country)
            tags.insert(idea.activityType)
            tags.insert(idea.source)
        }
        
        return Array(tags).sorted()
    }
    
    // Popular filters for the filter row
    static var popularFilters: [String] {
        ["Food", "Nature", "Adventure", "Japan", "Italy", "Instagram", "Urban", "Culture"]
    }
}

struct Board: Identifiable {
    let id = UUID()
    let title: String
    let ideasCount: Int
    let previewImageURLs: [String]
    let collaboratorImageURLs: [String]
    let createdAt: Date = Date().addingTimeInterval(-Double.random(in: 1...30) * 24 * 60 * 60)
    var ideas: [Idea] = [] // Linked ideas
    
    var createdAtText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    // Sample data with ideas filled in
    static var samples: [Board] {
        let japanBoard = Board(
            title: "Japan 2025",
            ideasCount: 10,
            previewImageURLs: [
                "https://picsum.photos/300/200?random=21",
                "https://picsum.photos/300/200?random=22",
                "https://picsum.photos/300/200?random=23",
                "https://picsum.photos/300/200?random=24"
            ],
            collaboratorImageURLs: [
                "https://i.pravatar.cc/150?img=1",
                "https://i.pravatar.cc/150?img=2"
            ]
        )
        
        let europeBoard = Board(
            title: "European Adventure",
            ideasCount: 6,
            previewImageURLs: [
                "https://picsum.photos/300/200?random=31",
                "https://picsum.photos/300/200?random=32",
                "https://picsum.photos/300/200?random=33"
            ],
            collaboratorImageURLs: [
                "https://i.pravatar.cc/150?img=3",
                "https://i.pravatar.cc/150?img=4",
                "https://i.pravatar.cc/150?img=5"
            ]
        )
        
        let weekendBoard = Board(
            title: "Weekend Getaways",
            ideasCount: 4,
            previewImageURLs: [
                "https://picsum.photos/300/200?random=41",
                "https://picsum.photos/300/200?random=42"
            ],
            collaboratorImageURLs: [
                "https://i.pravatar.cc/150?img=6"
            ]
        )
        
        let morningtonBoard = Board(
            title: "Mornington 2024",
            ideasCount: 3,
            previewImageURLs: [
                "https://picsum.photos/300/200?random=51",
                "https://picsum.photos/300/200?random=52",
                "https://picsum.photos/300/200?random=53",
                "https://picsum.photos/300/200?random=54"
            ],
            collaboratorImageURLs: [
                "https://i.pravatar.cc/150?img=7",
                "https://i.pravatar.cc/150?img=8"
            ]
        )
        
        // Store board IDs to use for idea association
        BoardStore.shared.boards = [japanBoard, europeBoard, weekendBoard, morningtonBoard]
        
        // Return the boards with their associated ideas
        return BoardStore.shared.boards
    }
    
    // Helper to get ideas for a specific board
    static func ideasFor(boardID: UUID) -> [Idea] {
        // Get from store if available
        if let boardIdeas = BoardStore.shared.ideasByBoardID[boardID] {
            return boardIdeas
        }
        
        // Otherwise create some dummy ideas for this board
        let board = BoardStore.shared.boards.first(where: { $0.id == boardID })
        let theme = board?.title ?? "Travel"
        let count = board?.ideasCount ?? 5
        
        let ideas = Idea.ideasForBoard(boardID: boardID, count: count, theme: theme)
        BoardStore.shared.ideasByBoardID[boardID] = ideas
        
        return ideas
    }
}

// Store to maintain board-idea relationships across the app
class BoardStore {
    static let shared = BoardStore()
    
    var boards: [Board] = []
    var ideasByBoardID: [UUID: [Idea]] = [:]
    
    private init() {}
} 