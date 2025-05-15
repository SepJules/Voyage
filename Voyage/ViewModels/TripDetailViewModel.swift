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
    func addActivity(dayId: UUID, timeOfDay: TripActivity.TimeOfDay, activityData: ActivityData) {
        // Find the day
        if let dayIndex = tripDays.firstIndex(where: { $0.id == dayId }) {
            // If we have a place ID, fetch coordinates from Google Maps API
            if let placeId = activityData.placeId {
                // We could fetch coordinates here, but for now we'll check if they're already included
                // In a real implementation, you'd make an API call to get coordinates if not available
                
                // For places from Google Places search, we need to make sure coordinates are set
                if activityData.sourceType == "Google Places" && (activityData.latitude == nil || activityData.longitude == nil) {
                    // Trigger fetch of place details to get coordinates
                    let placesService = GooglePlacesService()
                    placesService.getPlaceDetails(placeId: placeId) { details, error in
                        if let details = details {
                            // Now create and add the activity with coordinates
                            let latitude = details.geometry.location.lat
                            let longitude = details.geometry.location.lng
                            
                            DispatchQueue.main.async {
                                self.addActivityWithCoordinates(
                                    dayId: dayId,
                                    dayIndex: dayIndex,
                                    timeOfDay: timeOfDay,
                                    activityData: activityData,
                                    latitude: latitude,
                                    longitude: longitude
                                )
                            }
                        } else {
                            // If details fetch failed, add activity without coordinates
                            DispatchQueue.main.async {
                                self.addActivityWithCoordinates(
                                    dayId: dayId,
                                    dayIndex: dayIndex,
                                    timeOfDay: timeOfDay,
                                    activityData: activityData,
                                    latitude: nil,
                                    longitude: nil
                                )
                            }
                        }
                    }
                    return // Exit early as we'll add the activity in the callback
                }
            }
            
            // If we get here, either we have coordinates or we don't need to fetch them
            addActivityWithCoordinates(
                dayId: dayId,
                dayIndex: dayIndex,
                timeOfDay: timeOfDay,
                activityData: activityData,
                latitude: activityData.latitude,
                longitude: activityData.longitude
            )
        }
    }
    
    // Helper method to add activity with coordinates
    private func addActivityWithCoordinates(dayId: UUID, dayIndex: Int, timeOfDay: TripActivity.TimeOfDay, activityData: ActivityData, latitude: Double?, longitude: Double?) {
        // Create a new activity
        let newActivity = TripActivity(
            id: UUID(),
            title: activityData.title,
            location: activityData.location,
            sourceType: activityData.sourceType,
            placeId: activityData.placeId,
            linkedIdeaId: activityData.ideaId,
            photoReference: activityData.photoReference,
            timeOfDay: timeOfDay,
            latitude: latitude,
            longitude: longitude,
            activityType: activityData.activityType,
            rating: activityData.rating
        )
        
        // Add to the appropriate time slot
        var updatedDay = tripDays[dayIndex]
        
        switch timeOfDay {
        case .morning:
            updatedDay.segments.morning.append(newActivity)
        case .afternoon:
            updatedDay.segments.afternoon.append(newActivity)
        case .evening:
            updatedDay.segments.evening.append(newActivity)
        }
        
        // Update the day
        tripDays[dayIndex] = updatedDay
        
        // Save changes
        saveTrip()
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
    
    // Reorder activities within a time slot
    func reorderActivities(dayId: UUID, timeOfDay: TripActivity.TimeOfDay, fromIndex: Int, toIndex: Int) {
        guard let dayIndex = tripDays.firstIndex(where: { $0.id == dayId }) else { return }
        
        var updatedDay = tripDays[dayIndex]
        
        switch timeOfDay {
        case .morning:
            guard fromIndex < updatedDay.segments.morning.count && toIndex < updatedDay.segments.morning.count else { return }
            let activity = updatedDay.segments.morning.remove(at: fromIndex)
            updatedDay.segments.morning.insert(activity, at: toIndex)
            
        case .afternoon:
            guard fromIndex < updatedDay.segments.afternoon.count && toIndex < updatedDay.segments.afternoon.count else { return }
            let activity = updatedDay.segments.afternoon.remove(at: fromIndex)
            updatedDay.segments.afternoon.insert(activity, at: toIndex)
            
        case .evening:
            guard fromIndex < updatedDay.segments.evening.count && toIndex < updatedDay.segments.evening.count else { return }
            let activity = updatedDay.segments.evening.remove(at: fromIndex)
            updatedDay.segments.evening.insert(activity, at: toIndex)
        }
        
        // Update the day with the reordered activities
        tripDays[dayIndex] = updatedDay
        
        // Save changes
        saveTrip()
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