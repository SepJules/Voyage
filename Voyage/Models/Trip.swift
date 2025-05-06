//
//  Trip.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import Foundation

struct Trip: Identifiable, Codable {
    var id = UUID()
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var activities: [Activity]
    var notes: String
    var isFavorite: Bool = false
    var isCompleted: Bool = false
    var collaborators: [String] = [] // URLs for collaborator profile images
    
    // Location details - now supports multiple cities and countries
    var cities: [String]
    var countries: [String]
    
    // Ideas associated with this trip
    var ideasCount: Int = 0
    
    // Formatted dates for display
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate))"
    }
    
    // Location display text
    var locationDisplayText: String {
        if cities.count == 1 && countries.count == 1 {
            return "\(cities[0]), \(countries[0])"
        } else {
            let citiesText = cities.count == 1 ? "1 city" : "\(cities.count) cities"
            let countriesText = countries.count == 1 ? "1 country" : "\(countries.count) countries"
            return "\(citiesText) in \(countriesText)"
        }
    }
    
    // For backward compatibility
    var city: String {
        return cities.first ?? ""
    }
    
    var country: String {
        return countries.first ?? ""
    }
    
    // Sample data
    static var upcomingSamples: [Trip] {
        [
            Trip(
                name: "Summer Vacation",
                destination: "Greece Islands",
                startDate: Date().addingTimeInterval(60*24*60*60), // 60 days in future
                endDate: Date().addingTimeInterval(70*24*60*60),
                activities: [Activity.sample],
                notes: "Remember to pack sunscreen!",
                collaborators: [], // Empty collaborators list
                cities: ["Santorini", "Athens", "Mykonos"],
                countries: ["Greece"],
                ideasCount: 5
            ),
            Trip(
                name: "Business Trip",
                destination: "Washington DC",
                startDate: Date().addingTimeInterval(10*24*60*60), // 10 days in future
                endDate: Date().addingTimeInterval(12*24*60*60),
                activities: [],
                notes: "Conference at Grand Hyatt",
                collaborators: [], // Empty collaborators list
                cities: ["Washington"],
                countries: ["United States"],
                ideasCount: 2
            )
        ]
    }
    
    static var completedSamples: [Trip] {
        [
            Trip(
                name: "Winter Getaway",
                destination: "Swiss Alps",
                startDate: Date().addingTimeInterval(-40*24*60*60), // 40 days in past
                endDate: Date().addingTimeInterval(-35*24*60*60),
                activities: [],
                notes: "Amazing ski trip!",
                isCompleted: true,
                collaborators: [], // Empty collaborators list
                cities: ["Zermatt"],
                countries: ["Switzerland"],
                ideasCount: 1
            ),
            Trip(
                name: "Weekend Escape",
                destination: "Napa Valley",
                startDate: Date().addingTimeInterval(-15*24*60*60), // 15 days in past
                endDate: Date().addingTimeInterval(-13*24*60*60),
                activities: [],
                notes: "Wine tasting tour",
                isCompleted: true,
                cities: ["Napa"],
                countries: ["United States"],
                ideasCount: 0
            ),
            Trip(
                name: "European Tour",
                destination: "Europe",
                startDate: Date().addingTimeInterval(-90*24*60*60), // 90 days in past
                endDate: Date().addingTimeInterval(-75*24*60*60),
                activities: [],
                notes: "Amazing journey through multiple countries",
                isCompleted: true,
                collaborators: [], // Empty collaborators list
                cities: ["Amsterdam", "Paris", "Barcelona", "Rome"],
                countries: ["Netherlands", "France", "Spain", "Italy"],
                ideasCount: 12
            )
        ]
    }
}

struct Activity: Identifiable, Codable {
    var id = UUID()
    var name: String
    var date: Date
    var location: String
    var notes: String
    
    // Sample data
    static var sample: Activity {
        Activity(
            name: "Visit Acropolis",
            date: Date().addingTimeInterval(24*60*60),
            location: "Athens",
            notes: "Open from 8am to 8pm"
        )
    }
} 