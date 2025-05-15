//
//  AddActivityModalView.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import SwiftUI

// Data structure to handle activity selection from either search or saved ideas
struct ActivityData {
    var title: String
    var location: String
    var sourceType: String
    var placeId: String? // Google Places ID if from search
    var ideaId: UUID? // Optional reference to saved idea if from saved ideas
    var photoReference: String? // Google Places photo reference
    var latitude: Double? // Coordinates for map display
    var longitude: Double? // Coordinates for map display
    var activityType: String? // Type of activity (e.g., "Restaurant", "Museum", "Outdoor")
    var rating: Double? // Google rating if available
    
    // Factory method for creating from Google Places result
    static func fromPlaceResult(_ place: PlaceResult) -> ActivityData {
        return ActivityData(
            title: place.name,
            location: place.address,
            sourceType: "Google Places",
            placeId: place.placeId,
            ideaId: nil,
            photoReference: nil, // Photo reference will be fetched when details are requested
            latitude: nil, // Coordinates will be fetched when details are requested
            longitude: nil,
            activityType: nil, // Type will be fetched when details are requested
            rating: nil // Rating will be fetched when details are requested
        )
    }
    
    // Factory method for creating from PlaceDetails 
    static func fromPlaceDetails(_ details: PlaceDetails) -> ActivityData {
        // Determine activity type from place types if available
        let activityType = determineActivityType(from: details.types)
        
        return ActivityData(
            title: details.name,
            location: details.formattedAddress,
            sourceType: "Google Places",
            placeId: details.placeID,
            ideaId: nil,
            photoReference: details.photos?.first?.photoReference,
            latitude: details.geometry.location.lat,
            longitude: details.geometry.location.lng,
            activityType: activityType,
            rating: details.rating
        )
    }
    
    // Factory method for creating from saved idea
    static func fromIdea(_ idea: Idea) -> ActivityData {
        return ActivityData(
            title: idea.title,
            location: idea.location,
            sourceType: idea.source,
            placeId: idea.placeId, // Ideas might have a placeId if they were originally from Google
            ideaId: idea.id,
            photoReference: idea.photoReference,
            latitude: nil,
            longitude: nil,
            activityType: idea.activityType, // Use the idea's activity type
            rating: nil // Ideas don't have ratings yet
        )
    }
    
    // Helper method to determine activity type from place types
    private static func determineActivityType(from types: [String]?) -> String? {
        guard let types = types, !types.isEmpty else { return nil }
        
        // Map Google place types to user-friendly categories
        if types.contains("restaurant") || types.contains("food") {
            return "Restaurant"
        } else if types.contains("cafe") {
            return "Cafe"
        } else if types.contains("museum") {
            return "Museum"
        } else if types.contains("park") || types.contains("natural_feature") {
            return "Outdoor"
        } else if types.contains("tourist_attraction") || types.contains("point_of_interest") {
            return "Attraction"
        } else if types.contains("lodging") || types.contains("hotel") {
            return "Accommodation"
        } else if types.contains("shopping_mall") || types.contains("store") {
            return "Shopping"
        } else if types.contains("bar") || types.contains("night_club") {
            return "Nightlife"
        } else {
            // Return the first type, capitalized
            return types.first?.capitalized
        }
    }
}

// Google Places result structure (used for autocomplete suggestions)
struct PlaceResult: Identifiable {
    let id = UUID() // This is a local ID for the list
    let name: String
    let address: String
    let placeId: String // This is the Google Place ID
}

struct AddActivityModalView: View {
    let trip: Trip
    let savedIdeas: [Idea]
    let onSelectActivity: (ActivityData) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var searchResults: [PlaceResult] = [] // Remains PlaceResult for suggestions
    @State private var isSearching = false
    @State private var isFetchingDetails = false // To show activity for details fetch
    
    private let placesService = GooglePlacesService()
    
    private func searchPlaces(query: String) {
        if query.isEmpty {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        placesService.getPlaceSuggestions(query: query) { suggestions, error in
            DispatchQueue.main.async {
                isSearching = false
                if let error = error {
                    print("[GooglePlacesService] Error fetching place suggestions: \(error.localizedDescription)")
                    searchResults = []
                    return
                }
                
                if let suggestions = suggestions {
                    searchResults = suggestions.map {
                        // We use the Google Place ID (s.id) for the placeId field
                        PlaceResult(name: $0.name, address: $0.address, placeId: $0.id)
                    }
                } else {
                    searchResults = []
                }
            }
        }
    }
    
    private func handleSelectPlaceResult(_ placeResult: PlaceResult) {
        isFetchingDetails = true
        placesService.getPlaceDetails(placeId: placeResult.placeId) { details, error in
            DispatchQueue.main.async {
                isFetchingDetails = false
                if let error = error {
                    print("Error fetching place details: \(error.localizedDescription)")
                    // For now, create basic ActivityData from the search result instead
                    let basicActivity = ActivityData.fromPlaceResult(placeResult)
                    onSelectActivity(basicActivity)
                    dismiss()
                    return
                }
                
                if let details = details {
                    let activityData = ActivityData.fromPlaceDetails(details)
                    onSelectActivity(activityData)
                    dismiss()
                } else {
                    // Fallback to basic data
                    let basicActivity = ActivityData.fromPlaceResult(placeResult)
                    onSelectActivity(basicActivity)
                    dismiss()
                }
            }
        }
    }
    
    var body: some View {
        NavigationView { // Wrap in NavigationView for a title bar if desired, or just VStack
            VStack(spacing: 0) {
                // Header with title and close button
                HStack {
                    Text("Add Activity")
                        .font(.headline)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                // Search section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Search for places")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search for places", text: $searchText)
                            .onChange(of: searchText) { _, newValue in
                                searchPlaces(query: newValue)
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if isSearching {
                            ProgressView()
                                .padding(.leading, 4)
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                
                if isFetchingDetails {
                    ProgressView("Fetching details...")
                        .padding()
                }

                // Search results
                if !searchResults.isEmpty && !isFetchingDetails {
                    List {
                        Section(header: Text("Search Results")) {
                            ForEach(searchResults) { result in
                                Button(action: { handleSelectPlaceResult(result) }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(result.name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(result.address)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                } else if !isFetchingDetails {
                    // Saved ideas section (only if not searching/showing search results and not fetching details)
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            Text("Saved Ideas")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            if savedIdeas.isEmpty {
                                EmptyStateView(
                                    icon: "star",
                                    title: "No saved ideas yet",
                                    message: "Search for places or add ideas to your trip"
                                )
                                .padding(.top, 24)
                                .padding(.horizontal, 20) // Add horizontal padding
                            } else {
                                ForEach(savedIdeas) { idea in
                                    Button(action: {
                                        let activityData = ActivityData.fromIdea(idea)
                                        onSelectActivity(activityData)
                                        dismiss() // Dismiss modal after selection
                                    }) {
                                        SavedIdeaCard(idea: idea)
                                            .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.bottom, 16)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            // .navigationTitle("Add Activity") // Use if NavigationView is kept
            // .navigationBarItems(trailing: Button(action: { dismiss() }) { Text("Cancel") }) // Alternative dismiss
        }
    }
}

// Card for saved ideas
struct SavedIdeaCard: View {
    let idea: Idea
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Optional image placeholder
            if idea.hasImage {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }
            
            // Idea content
            VStack(alignment: .leading, spacing: 4) {
                Text(idea.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(idea.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(idea.activityType)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Source tag
                    HStack(spacing: 2) {
                        Image(systemName: "link")
                            .font(.system(size: 8))
                        
                        Text(idea.source)
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray6))
                    .cornerRadius(4)
                }
            }
            
            Spacer()
            
            Image(systemName: "plus.circle")
                .foregroundColor(.teal)
                .font(.system(size: 18))
        }
        .padding(12)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(10)
    }
}

#Preview {
    // Preview with mock data
    AddActivityModalView(
        trip: Trip.upcomingSamples[0],
        savedIdeas: [
            Idea(
                title: "Beach Day", 
                tag: "Outdoor",
                imageURL: "https://picsum.photos/300/200?random=1",
                city: "Santorini", 
                country: "Greece", 
                activityType: "Outdoor", 
                source: "User"
            ),
            Idea(
                title: "Wine Tasting", 
                tag: "Food & Drink",
                imageURL: "https://picsum.photos/300/200?random=2",
                city: "Santorini", 
                country: "Greece", 
                activityType: "Food & Drink", 
                source: "Instagram"
            )
        ],
        onSelectActivity: { _ in }
    )
} 