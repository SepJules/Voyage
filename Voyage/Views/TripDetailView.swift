//
//  TripDetailView.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct TripDetailView: View {
    @StateObject private var viewModel: TripDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var notes: String = ""
    @State private var viewMode: ViewMode = .timeline // Combined view mode
    @State private var showingAddActivityModal = false
    @State private var selectedDayId: UUID?
    @State private var selectedTimeOfDay: TripActivity.TimeOfDay?
    
    enum ViewMode {
        case timeline
        case map
        case ideas
    }
    
    init(trip: Trip) {
        _viewModel = StateObject(wrappedValue: TripDetailViewModel(trip: trip))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Single unified toggle for Timeline/Map/Ideas
            Picker("View Mode", selection: $viewMode) {
                Text("Timeline").tag(ViewMode.timeline)
                Text("Map").tag(ViewMode.map)
                Text("Ideas").tag(ViewMode.ideas)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            // Content based on selected view mode
            switch viewMode {
            case .timeline:
                // Timeline View
                itineraryView
            case .map:
                // Map View
                TripMapView(
                    viewModel: viewModel,
                    tripDays: viewModel.tripDays
                )
            case .ideas:
                // Ideas View
                TripIdeasView(viewModel: viewModel)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        viewModel.showingEditTrip = true
                    }) {
                        Label("Edit Trip", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        viewModel.shareTrip()
                    }) {
                        Label("Share Trip", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive, action: {
                        viewModel.showingDeleteConfirm = true
                    }) {
                        Label("Delete Trip", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(8)
                }
            }
        }
        .overlay(
            // Only show FAB in Timeline mode
            viewMode == .timeline ?
            AnyView(Button(action: {
                // Default action - expand to show options
                if let firstDay = viewModel.tripDays.first {
                    viewModel.prepareToAddActivity(dayId: firstDay.id, timeOfDay: .morning)
                }
            }) {
                ZStack {
                    Circle()
                        .foregroundColor(.teal)
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 16)
            .padding(.trailing, 16)) : AnyView(EmptyView()),
            alignment: .bottomTrailing
        )
        .sheet(isPresented: $viewModel.showingEditTrip) {
            EditTripView(trip: viewModel.trip) { updatedTrip in
                viewModel.trip = updatedTrip
                viewModel.saveTrip()
            }
        }
        .sheet(isPresented: $showingAddActivityModal) {
            // Reset selected day and time of day when modal is dismissed
            selectedDayId = nil
            selectedTimeOfDay = nil
        } content: {
            if let dayId = selectedDayId, let timeOfDay = selectedTimeOfDay {
                AddActivityModalView(
                    trip: viewModel.trip,
                    savedIdeas: viewModel.trip.savedIdeas,
                    onSelectActivity: { activityData in
                        // Add the selected activity to the day and time slot
                        viewModel.addActivity(dayId: dayId, timeOfDay: timeOfDay, activityData: activityData)
                        showingAddActivityModal = false
                    }
                )
            }
        }
        .alert("Delete Trip?", isPresented: $viewModel.showingDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteTrip()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this trip? This action cannot be undone.")
        }
        .sheet(isPresented: $viewModel.showingAddIdeasSheet) {
            // This would be the view to select ideas to add
            VStack {
                Text("Select Ideas to Add")
                    .font(.headline)
                    .padding()
                
                // This is a placeholder - would be replaced with real ideas selection view
                Button("Close") {
                    viewModel.showingAddIdeasSheet = false
                }
                .padding()
            }
        }
    }
    
    // Itinerary View - moved the ScrollView content to a separate property for better organization
    private var itineraryView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                // MARK: - Trip Header Section (Sticky)
                Section(header: TripHeaderView(viewModel: viewModel)) {
                    Color.clear.frame(height: 16) // Spacer
                }
                
                // MARK: - Daily Itinerary Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Daily Itinerary")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 16)
                        
                        if viewModel.tripDays.isEmpty {
                            EmptyStateView(
                                icon: "calendar",
                                title: "No days planned yet",
                                message: "Start adding activities to your trip"
                            )
                        } else {
                            ForEach(viewModel.tripDays.sorted { $0.date < $1.date }) { day in
                                DayItineraryCard(
                                    day: day,
                                    isExpanded: viewModel.isDayExpanded(day.id),
                                    onToggleExpand: {
                                        viewModel.toggleDayExpanded(day.id)
                                    },
                                    onAddActivity: { timeOfDay in
                                        selectedDayId = day.id
                                        selectedTimeOfDay = timeOfDay
                                        showingAddActivityModal = true
                                    },
                                    onRemoveActivity: { activityId, timeOfDay in
                                        viewModel.removeActivity(dayId: day.id, activityId: activityId, timeOfDay: timeOfDay)
                                    },
                                    onReorderActivity: { timeOfDay, fromIndex, toIndex in
                                        viewModel.reorderActivities(dayId: day.id, timeOfDay: timeOfDay, fromIndex: fromIndex, toIndex: toIndex)
                                    }
                                )
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                
                // MARK: - Notes Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Trip Notes")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 24)
                            .padding(.bottom, 8)
                        
                        // Use local state for the notes to avoid constant updates
                        TextEditor(text: $notes)
                            .frame(minHeight: 150)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .onAppear {
                                notes = viewModel.trip.notes
                            }
                            .onDisappear {
                                if notes != viewModel.trip.notes {
                                    viewModel.updateNotes(notes)
                                }
                            }
                    }
                }
                .padding(.bottom, 100) // Space for FAB and tab bar
            }
        }
    }
}

// MARK: - Trip Header
struct TripHeaderView: View {
    @ObservedObject var viewModel: TripDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header background
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 110)
                    .shadow(color: Color.gray.opacity(0.2), radius: 2, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Trip name
                    Text(viewModel.trip.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Trip dates
                    Text(viewModel.trip.dateRangeText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Trip location
                    Text(viewModel.trip.locationDisplayText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal)
            }
        }
        .background(Color.white)
        .zIndex(1)
    }
}

// MARK: - Day Itinerary Card
struct DayItineraryCard: View {
    let day: TripDay
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onAddActivity: (TripActivity.TimeOfDay) -> Void
    let onRemoveActivity: (UUID, TripActivity.TimeOfDay) -> Void
    let onReorderActivity: (TripActivity.TimeOfDay, Int, Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header (always visible)
            Button(action: onToggleExpand) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(day.formattedDate)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(day.city)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Expand/collapse chevron
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .padding(8)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(isExpanded ? 12 : 12)
            }
            
            // Expanded content
            if isExpanded {
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    TimeSegmentView(
                        title: "Morning", 
                        activities: day.segments.morning,
                        dayId: day.id,
                        timeOfDay: .morning,
                        onAdd: { onAddActivity(.morning) },
                        onRemove: { activityId in onRemoveActivity(activityId, .morning) },
                        onReorder: { fromIndex, toIndex in
                            onReorderActivity(.morning, fromIndex, toIndex)
                        }
                    )
                    
                    Divider()
                    
                    TimeSegmentView(
                        title: "Afternoon", 
                        activities: day.segments.afternoon,
                        dayId: day.id,
                        timeOfDay: .afternoon,
                        onAdd: { onAddActivity(.afternoon) },
                        onRemove: { activityId in onRemoveActivity(activityId, .afternoon) },
                        onReorder: { fromIndex, toIndex in
                            onReorderActivity(.afternoon, fromIndex, toIndex)
                        }
                    )
                    
                    Divider()
                    
                    TimeSegmentView(
                        title: "Evening", 
                        activities: day.segments.evening,
                        dayId: day.id,
                        timeOfDay: .evening,
                        onAdd: { onAddActivity(.evening) },
                        onRemove: { activityId in onRemoveActivity(activityId, .evening) },
                        onReorder: { fromIndex, toIndex in
                            onReorderActivity(.evening, fromIndex, toIndex)
                        }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(12)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Time Segment View
struct TimeSegmentView: View {
    let title: String
    let activities: [TripActivity]
    let dayId: UUID // Add day ID to identify which day's activities we're reordering
    let timeOfDay: TripActivity.TimeOfDay // Add time of day to identify which segment we're reordering
    let onAdd: () -> Void
    let onRemove: (UUID) -> Void
    let onReorder: (Int, Int) -> Void // Add callback for reordering
    
    @State private var draggedItem: TripActivity?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.vertical, 4)
            
            if activities.isEmpty {
                // Empty state with add button
                Button(action: onAdd) {
                    HStack {
                        Image(systemName: "plus.circle")
                            .font(.caption)
                        
                        Text("Add Activity")
                            .font(.subheadline)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            } else {
                // List of activities
                ForEach(Array(activities.enumerated()), id: \.element.id) { index, activity in
                    ActivityItemView(activity: activity, onRemove: {
                        onRemove(activity.id)
                    })
                    .padding(.bottom, 4)
                    .onDrag {
                        // Set the dragged item for tracking
                        self.draggedItem = activity
                        // Return a simple NSItemProvider - we don't actually need to transfer data
                        return NSItemProvider(object: NSString(string: "activity"))
                    }
                    .onDrop(of: [UTType.text.identifier], delegate: ActivityDropDelegate(
                        item: activity,
                        items: activities,
                        draggedItem: $draggedItem,
                        onReorder: { fromIndex, toIndex in
                            onReorder(fromIndex, toIndex)
                        }
                    ))
                }
                
                // Add more activities button
                Button(action: onAdd) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.caption)
                        
                        Text("Add Another")
                            .font(.footnote)
                    }
                    .foregroundColor(.teal)
                    .padding(.top, 4)
                }
            }
        }
    }
}

// Drop delegate for activity reordering
struct ActivityDropDelegate: DropDelegate {
    let item: TripActivity
    let items: [TripActivity]
    @Binding var draggedItem: TripActivity?
    let onReorder: (Int, Int) -> Void
    
    func performDrop(info: DropInfo) -> Bool {
        // We already handled the reordering in dropEntered
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Get the dragged item and the destination item
        guard let draggedItem = self.draggedItem,
              let fromIndex = items.firstIndex(where: { $0.id == draggedItem.id }),
              let toIndex = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        // Only perform reordering if indices differ
        if fromIndex != toIndex {
            onReorder(fromIndex, toIndex)
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

// MARK: - Activity Item
struct ActivityItemView: View {
    let activity: TripActivity
    let onRemove: () -> Void
    private let apiKey = APIKeys.googlePlacesAPIKey // Access the API key
    @State private var isPressed = false

    var photoURL: URL? {
        guard let photoReference = activity.photoReference else { return nil }
        return URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photoreference=\(photoReference)&key=\(apiKey)")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Image View
            if let url = photoURL {
                AsyncImage(url: url) {
                    phase in
                    if let image = phase.image {
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                            .clipped()
                    } else if phase.error != nil {
                        // Error view or placeholder
                        Image(systemName: "photo") // Placeholder for error
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    } else {
                        // Placeholder while loading
                        ProgressView()
                            .frame(width: 60, height: 60)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                }
            } else {
                // Placeholder if no photo reference
                Image(systemName: "building.2") 
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(12)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            // Activity info
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(activity.location)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                Spacer() // Pushes content to the bottom
                
                HStack {
                    // Subtle drag handle icon
                    Image(systemName: "line.3.horizontal")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.6))
                        .padding(.top, 2)
                    
                    Spacer()
                    
                    // Activity type pill
                    if let activityType = activity.activityType {
                        Text(activityType)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.teal.opacity(0.1))
                            .foregroundColor(.teal)
                            .cornerRadius(4)
                    }
                    
                    // Rating pill if available
                    if let rating = activity.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            
                            Text(String(format: "%.1f", rating))
                                .font(.caption2)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.yellow.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                        .padding(.leading, 4)
                    }
                }
            }
            
            Spacer()
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.callout)
                    .foregroundColor(.gray.opacity(0.7))
            }
            .padding(.leading, -8) // Adjust spacing for a cleaner look
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: isPressed ? Color.teal.opacity(0.3) : Color.black.opacity(0.05), 
                       radius: isPressed ? 4 : 3, 
                       x: 0, 
                       y: isPressed ? 1 : 2)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.2, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Linked Idea Card
struct LinkedIdeaCard: View {
    let idea: Idea
    let onUnlink: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 100)
                .overlay(ProgressView())
                .cornerRadius(8, corners: [.topLeft, .topRight])
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(idea.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                // Subtitle (tags and location)
                Text("\(idea.activityType) · \(idea.city)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    // Source pill
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
                    
                    Spacer()
                    
                    // Menu button
                    Menu {
                        Button(action: onUnlink) {
                            Label("Unlink from Trip", systemImage: "link.badge.minus")
                        }
                        
                        Button(action: {}) {
                            Label("View Idea", systemImage: "eye")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(4)
                    }
                }
            }
            .padding(8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    NavigationView {
        TripDetailView(trip: Trip.upcomingSamples[0])
    }
} 