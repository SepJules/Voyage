//
//  TripDetailView.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import SwiftUI

struct TripDetailView: View {
    @StateObject private var viewModel: TripDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var notes: String = ""
    
    init(trip: Trip) {
        _viewModel = StateObject(wrappedValue: TripDetailViewModel(trip: trip))
    }
    
    var body: some View {
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
                                        viewModel.prepareToAddActivity(dayId: day.id, timeOfDay: timeOfDay)
                                    },
                                    onRemoveActivity: { activityId, timeOfDay in
                                        viewModel.removeActivity(dayId: day.id, activityId: activityId, timeOfDay: timeOfDay)
                                    }
                                )
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                
                // MARK: - Linked Ideas Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Trip Ideas")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.showAddIdeasSheet()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.caption)
                                    
                                    Text("Add Ideas")
                                        .font(.subheadline)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 24)
                        .padding(.bottom, 8)
                        
                        if viewModel.linkedIdeas.isEmpty {
                            EmptyStateView(
                                icon: "lightbulb",
                                title: "No ideas linked yet",
                                message: "Add ideas to help plan your trip"
                            )
                        } else {
                            // Grid of linked ideas
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(viewModel.linkedIdeas) { idea in
                                    LinkedIdeaCard(
                                        idea: idea,
                                        onUnlink: {
                                            viewModel.unlinkIdea(idea.id)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
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
            // Floating Action Button
            Button(action: {
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
            .padding(.trailing, 16),
            alignment: .bottomTrailing
        )
        .sheet(isPresented: $viewModel.showingEditTrip) {
            EditTripView(trip: viewModel.trip) { updatedTrip in
                viewModel.trip = updatedTrip
                viewModel.saveTrip()
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
                        onAdd: { onAddActivity(.morning) },
                        onRemove: { activityId in onRemoveActivity(activityId, .morning) }
                    )
                    
                    Divider()
                    
                    TimeSegmentView(
                        title: "Afternoon", 
                        activities: day.segments.afternoon,
                        onAdd: { onAddActivity(.afternoon) },
                        onRemove: { activityId in onRemoveActivity(activityId, .afternoon) }
                    )
                    
                    Divider()
                    
                    TimeSegmentView(
                        title: "Evening", 
                        activities: day.segments.evening,
                        onAdd: { onAddActivity(.evening) },
                        onRemove: { activityId in onRemoveActivity(activityId, .evening) }
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
    let onAdd: () -> Void
    let onRemove: (UUID) -> Void
    
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
                ForEach(activities) { activity in
                    ActivityItemView(activity: activity, onRemove: {
                        onRemove(activity.id)
                    })
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

// MARK: - Activity Item
struct ActivityItemView: View {
    let activity: TripActivity
    let onRemove: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Activity info
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    // Source tag
                    Text(activity.sourceType)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                    
                    // Location
                    Text(activity.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(6)
            }
        }
        .padding(10)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
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