//
//  DataService.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import Foundation

class DataService {
    private let tripsKey = "savedTrips"
    
    func saveTrips(_ trips: [Trip]) {
        if let encoded = try? JSONEncoder().encode(trips) {
            UserDefaults.standard.set(encoded, forKey: tripsKey)
        }
    }
    
    func loadTrips() -> [Trip] {
        if let data = UserDefaults.standard.data(forKey: tripsKey),
           let decoded = try? JSONDecoder().decode([Trip].self, from: data) {
            return decoded
        }
        
        return []
    }
} 