//
//  TripViewModel.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import Foundation
import Combine

class TripViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var upcomingTrips: [Trip] = []
    @Published var completedTrips: [Trip] = []
    
    private let dataService = DataService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadTrips()
    }
    
    func loadTrips() {
        // Load from data service
        trips = dataService.loadTrips()
        
        // For demo purposes, use sample data if empty
        if trips.isEmpty {
            upcomingTrips = Trip.upcomingSamples
            completedTrips = Trip.completedSamples
            trips = upcomingTrips + completedTrips
        } else {
            // Filter trips into upcoming and completed
            sortTrips()
        }
    }
    
    private func sortTrips() {
        upcomingTrips = trips.filter { !$0.isCompleted }
        completedTrips = trips.filter { $0.isCompleted }
    }
    
    func addTrip(_ trip: Trip) {
        trips.append(trip)
        if trip.isCompleted {
            completedTrips.append(trip)
        } else {
            upcomingTrips.append(trip)
        }
        saveTrips()
    }
    
    func updateTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
            sortTrips()
            saveTrips()
        }
    }
    
    func deleteTrip(at indexSet: IndexSet) {
        trips.remove(atOffsets: indexSet)
        sortTrips()
        saveTrips()
    }
    
    func toggleFavorite(for trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index].isFavorite.toggle()
            sortTrips()
            saveTrips()
        }
    }
    
    func markAsCompleted(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index].isCompleted = true
            sortTrips()
            saveTrips()
        }
    }
    
    private func saveTrips() {
        dataService.saveTrips(trips)
    }
} 