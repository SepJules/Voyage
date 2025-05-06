//
//  TripDetailViewModel.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import Foundation
import Combine

class TripDetailViewModel: ObservableObject {
    // Trip data
    @Published var trip: Trip
    @Published var tripDays: [TripDay] = []
    @Published var linkedIdeas: [Idea] = []
    
    // UI State
    @Published var isLoading: Bool = true
    @Published var expandedDays: Set<UUID> = []
    @Published var showingDeleteConfirm: Bool = false
    @Published var showingEditTrip: Bool = false
    @Published var showingShareSheet: Bool = false
    @Published var showingAddIdeasSheet: Bool = false
    @Published var selectedTimeOfDay: TripActivity.TimeOfDay?
    @Published var selectedDayId: UUID?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(trip: Trip) {
        self.trip = trip
        
        // Load data (using mock data for now)
        loadTripData()
    }
    
    // MARK: - Data Loading
    func loadTripData() {
        isLoading = true
        
        // In a real app, these would be API calls
        loadTripDays()
        loadLinkedIdeas()
        
        isLoading = false
    }
    
    private func loadTripDays() {
        // For demo, if no days exist yet, generate empty days for the date range
        if self.tripDays.isEmpty {
            if let sampleDays = TripDay.samples.first?.tripId == trip.id ? TripDay.samples : nil {
                // Use sample days if they match this trip
                self.tripDays = sampleDays
            } else {
                // Generate empty days
                self.tripDays = TripDay.generateDays(
                    tripId: trip.id,
                    from: trip.startDate,
                    to: trip.endDate,
                    cities: trip.cities
                )
            }
        }
    }
    
    private func loadLinkedIdeas() {
        // For demo, just load some random ideas
        self.linkedIdeas = Idea.samples.prefix(3).map { $0 }
    }
    
    // MARK: - Trip Operations
    func saveTrip() {
        // Would save to backend in a real app
        print("Saving trip: \(trip.name)")
    }
    
    func deleteTrip() {
        // Would delete from backend in a real app
        print("Deleting trip: \(trip.name)")
        showingDeleteConfirm = false
    }
    
    func shareTrip() {
        // Would generate share link in a real app
        print("Sharing trip: \(trip.name)")
        showingShareSheet = true
    }
    
    // MARK: - Day Operations
    func toggleDayExpanded(_ dayId: UUID) {
        if expandedDays.contains(dayId) {
            expandedDays.remove(dayId)
        } else {
            expandedDays.insert(dayId)
        }
    }
    
    func isDayExpanded(_ dayId: UUID) -> Bool {
        return expandedDays.contains(dayId)
    }
    
    // MARK: - Activity Operations
    func addActivity(ideaId: UUID, title: String, source: String, location: String, dayId: UUID, timeOfDay: TripActivity.TimeOfDay) {
        guard let dayIndex = tripDays.firstIndex(where: { $0.id == dayId }) else { return }
        
        let activity = TripActivity(
            ideaId: ideaId,
            title: title,
            sourceType: source,
            location: location,
            timeOfDay: timeOfDay
        )
        
        // Add to appropriate segment
        switch timeOfDay {
        case .morning:
            tripDays[dayIndex].segments.morning.append(activity)
        case .afternoon:
            tripDays[dayIndex].segments.afternoon.append(activity)
        case .evening:
            tripDays[dayIndex].segments.evening.append(activity)
        }
    }
    
    func removeActivity(dayId: UUID, activityId: UUID, timeOfDay: TripActivity.TimeOfDay) {
        guard let dayIndex = tripDays.firstIndex(where: { $0.id == dayId }) else { return }
        
        switch timeOfDay {
        case .morning:
            tripDays[dayIndex].segments.morning.removeAll { $0.id == activityId }
        case .afternoon:
            tripDays[dayIndex].segments.afternoon.removeAll { $0.id == activityId }
        case .evening:
            tripDays[dayIndex].segments.evening.removeAll { $0.id == activityId }
        }
    }
    
    // MARK: - Idea Operations
    func unlinkIdea(_ ideaId: UUID) {
        linkedIdeas.removeAll { $0.id == ideaId }
    }
    
    func showAddIdeasSheet() {
        showingAddIdeasSheet = true
    }
    
    func prepareToAddActivity(dayId: UUID, timeOfDay: TripActivity.TimeOfDay) {
        selectedDayId = dayId
        selectedTimeOfDay = timeOfDay
        showingAddIdeasSheet = true
    }
    
    // MARK: - Notes Operations
    func updateNotes(_ notes: String) {
        trip.notes = notes
    }
} 