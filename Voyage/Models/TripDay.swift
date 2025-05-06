//
//  TripDay.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import Foundation

// Model representing a day in a trip itinerary
struct TripDay: Identifiable, Codable {
    var id = UUID()
    var tripId: UUID
    var date: Date
    var city: String
    var segments: Segments
    
    // Morning, afternoon, evening segments of the day
    struct Segments: Codable {
        var morning: [TripActivity]
        var afternoon: [TripActivity]
        var evening: [TripActivity]
        
        // Check if all segments are empty
        var isEmpty: Bool {
            return morning.isEmpty && afternoon.isEmpty && evening.isEmpty
        }
    }
    
    // Formatted date display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }
    
    // Is this day empty of activities?
    var isEmpty: Bool {
        return segments.isEmpty
    }
    
    // Create an empty day
    static func emptyDay(tripId: UUID, date: Date, city: String) -> TripDay {
        return TripDay(
            tripId: tripId,
            date: date,
            city: city,
            segments: Segments(morning: [], afternoon: [], evening: [])
        )
    }
    
    // Sample data for preview
    static var samples: [TripDay] {
        let tripId = Trip.upcomingSamples.first?.id ?? UUID()
        let startDate = Date()
        
        return [
            TripDay(
                tripId: tripId,
                date: startDate,
                city: "Paris",
                segments: Segments(
                    morning: [
                        TripActivity(ideaId: UUID(), title: "Breakfast at Café Marais", sourceType: "Friend", location: "Le Marais, Paris")
                    ],
                    afternoon: [
                        TripActivity(ideaId: UUID(), title: "Louvre Museum", sourceType: "Travel Guide", location: "Rue de Rivoli, Paris")
                    ],
                    evening: [
                        TripActivity(ideaId: UUID(), title: "Dinner at Le Comptoir", sourceType: "Instagram", location: "Saint-Germain, Paris")
                    ]
                )
            ),
            TripDay(
                tripId: tripId,
                date: startDate.addingTimeInterval(24*60*60),
                city: "Paris",
                segments: Segments(
                    morning: [
                        TripActivity(ideaId: UUID(), title: "Eiffel Tower", sourceType: "Must-see", location: "Champ de Mars, Paris")
                    ],
                    afternoon: [
                        TripActivity(ideaId: UUID(), title: "Seine River Cruise", sourceType: "Recommendation", location: "Seine River, Paris")
                    ],
                    evening: []
                )
            ),
            TripDay(
                tripId: tripId,
                date: startDate.addingTimeInterval(2*24*60*60),
                city: "Nice",
                segments: Segments(
                    morning: [],
                    afternoon: [
                        TripActivity(ideaId: UUID(), title: "Promenade des Anglais", sourceType: "Blog", location: "Nice, France")
                    ],
                    evening: [
                        TripActivity(ideaId: UUID(), title: "Dinner at Le Safari", sourceType: "TripAdvisor", location: "Cours Saleya, Nice")
                    ]
                )
            )
        ]
    }
    
    // Generate a sequence of empty days between two dates
    static func generateDays(tripId: UUID, from startDate: Date, to endDate: Date, cities: [String]) -> [TripDay] {
        var days: [TripDay] = []
        var currentDate = startDate
        
        // Use Calendar to iterate through days
        let calendar = Calendar.current
        
        while currentDate <= endDate {
            // Determine which city to use based on the day's position in the trip
            let totalDays = calendar.dateComponents([.day], from: startDate, to: endDate).day! + 1
            let currentDayNumber = calendar.dateComponents([.day], from: startDate, to: currentDate).day!
            
            // Select city based on relative position in trip
            let cityIndex = min(cities.count - 1, Int(Double(currentDayNumber) / Double(totalDays) * Double(cities.count)))
            let city = cities[cityIndex]
            
            days.append(emptyDay(tripId: tripId, date: currentDate, city: city))
            
            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return days
    }
}

// Model representing an activity in a trip day
struct TripActivity: Identifiable, Codable {
    var id = UUID()
    var ideaId: UUID
    var title: String
    var sourceType: String
    var location: String
    var timeOfDay: TimeOfDay = .morning
    
    enum TimeOfDay: String, Codable, CaseIterable {
        case morning = "Morning"
        case afternoon = "Afternoon"
        case evening = "Evening"
    }
} 