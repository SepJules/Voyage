//
//  DragDropPlannerView.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import SwiftUI

struct DragDropPlannerView: View {
    @ObservedObject var tripDetailViewModel: TripDetailViewModel
    @StateObject private var videoService = VideoService()
    @State private var draggedVideo: Video?
    @State private var draggedActivity: TripActivity?
    @State private var showingVideoLibrary = false
    @State private var selectedDayId: UUID?
    @State private var selectedTimeOfDay: TripActivity.TimeOfDay?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Trip Planner")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showingVideoLibrary = true
                }) {
                    Label("Add Videos", systemImage: "film")
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Days list
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(tripDetailViewModel.tripDays) { day in
                        DayPlannerCard(
                            day: day,
                            isExpanded: tripDetailViewModel.isDayExpanded(day.id),
                            onToggleExpand: {
                                tripDetailViewModel.toggleDayExpanded(day.id)
                            },
                            onAddVideo: { timeOfDay in
                                selectedDayId = day.id
                                selectedTimeOfDay = timeOfDay
                                showingVideoLibrary = true
                            },
                            onDropVideo: { video, timeOfDay in
                                addVideoToDay(video: video, dayId: day.id, timeOfDay: timeOfDay)
                            },
                            onRemoveActivity: { activityId, timeOfDay in
                                tripDetailViewModel.removeActivity(dayId: day.id, activityId: activityId, timeOfDay: timeOfDay)
                            },
                            onMoveActivity: { activity, newTimeOfDay in
                                moveActivity(activity: activity, fromDayId: day.id, toTimeOfDay: newTimeOfDay)
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingVideoLibrary) {
            VideoPicker(
                videoService: videoService,
                onSelectVideos: { videos in
                    if let dayId = selectedDayId, let timeOfDay = selectedTimeOfDay {
                        for video in videos {
                            addVideoToDay(video: video, dayId: dayId, timeOfDay: timeOfDay)
                        }
                    }
                }
            )
        }
    }
    
    // Add a video to a specific day and time
    private func addVideoToDay(video: Video, dayId: UUID, timeOfDay: TripActivity.TimeOfDay) {
        // Associate video with trip
        videoService.associateVideoWithTrip(video, tripId: tripDetailViewModel.trip.id)
        
        // Create activity from video
        let activity = TripActivity(
            ideaId: UUID(), // Using a placeholder UUID since this is a video
            title: video.title,
            sourceType: video.source.rawValue,
            location: video.location?.city ?? "",
            timeOfDay: timeOfDay
        )
        
        // Add to trip day
        tripDetailViewModel.addActivity(
            ideaId: activity.ideaId,
            title: activity.title,
            source: activity.sourceType,
            location: activity.location,
            dayId: dayId,
            timeOfDay: timeOfDay
        )
    }
    
    // Move an activity to a different time of day
    private func moveActivity(activity: TripActivity, fromDayId: UUID, toTimeOfDay: TripActivity.TimeOfDay) {
        // First remove from original position
        tripDetailViewModel.removeActivity(dayId: fromDayId, activityId: activity.id, timeOfDay: activity.timeOfDay)
        
        // Then add to new position
        tripDetailViewModel.addActivity(
            ideaId: activity.ideaId,
            title: activity.title,
            source: activity.sourceType,
            location: activity.location,
            dayId: fromDayId,
            timeOfDay: toTimeOfDay
        )
    }
}

// Day planner card with drag and drop support
struct DayPlannerCard: View {
    let day: TripDay
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onAddVideo: (TripActivity.TimeOfDay) -> Void
    let onDropVideo: (Video, TripActivity.TimeOfDay) -> Void
    let onRemoveActivity: (UUID, TripActivity.TimeOfDay) -> Void
    let onMoveActivity: (TripActivity, TripActivity.TimeOfDay) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Day header
            Button(action: onToggleExpand) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(day.formattedDate)
                            .font(.headline)
                        
                        Text(day.city)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Day content when expanded
            if isExpanded {
                VStack(spacing: 16) {
                    // Morning segment
                    PlannerTimeSegmentView(
                        title: "Morning",
                        activities: day.segments.morning,
                        timeOfDay: .morning,
                        onAddVideo: { onAddVideo(.morning) },
                        onDropVideo: { video in
                            onDropVideo(video, .morning)
                        },
                        onRemoveActivity: { activityId in
                            onRemoveActivity(activityId, .morning)
                        },
                        onMoveActivity: { activity, newTimeOfDay in
                            onMoveActivity(activity, newTimeOfDay)
                        }
                    )
                    
                    // Afternoon segment
                    PlannerTimeSegmentView(
                        title: "Afternoon",
                        activities: day.segments.afternoon,
                        timeOfDay: .afternoon,
                        onAddVideo: { onAddVideo(.afternoon) },
                        onDropVideo: { video in
                            onDropVideo(video, .afternoon)
                        },
                        onRemoveActivity: { activityId in
                            onRemoveActivity(activityId, .afternoon)
                        },
                        onMoveActivity: { activity, newTimeOfDay in
                            onMoveActivity(activity, newTimeOfDay)
                        }
                    )
                    
                    // Evening segment
                    PlannerTimeSegmentView(
                        title: "Evening",
                        activities: day.segments.evening,
                        timeOfDay: .evening,
                        onAddVideo: { onAddVideo(.evening) },
                        onDropVideo: { video in
                            onDropVideo(video, .evening)
                        },
                        onRemoveActivity: { activityId in
                            onRemoveActivity(activityId, .evening)
                        },
                        onMoveActivity: { activity, newTimeOfDay in
                            onMoveActivity(activity, newTimeOfDay)
                        }
                    )
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Time segment view for drag and drop planner (Morning, Afternoon, Evening)
struct PlannerTimeSegmentView: View {
    let title: String
    let activities: [TripActivity]
    let timeOfDay: TripActivity.TimeOfDay
    let onAddVideo: () -> Void
    let onDropVideo: (Video) -> Void
    let onRemoveActivity: (UUID) -> Void
    let onMoveActivity: (TripActivity, TripActivity.TimeOfDay) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Button(action: onAddVideo) {
                    Label("Add", systemImage: "plus")
                        .font(.caption)
                        .foregroundColor(.teal)
                }
            }
            
            // Drop area for videos
            ZStack {
                if activities.isEmpty {
                    // Empty state
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundColor(Color.gray.opacity(0.5))
                        .frame(height: 60)
                        .overlay(
                            Text("Drop videos here")
                                .font(.caption)
                                .foregroundColor(.gray)
                        )
                        .onDrop(of: ["video.item"], isTargeted: nil) { providers, _ in
                            // Handle drop
                            return false
                        }
                } else {
                    // List of activities
                    VStack(spacing: 8) {
                        ForEach(activities) { activity in
                            ActivityCard(
                                activity: activity,
                                onRemove: {
                                    onRemoveActivity(activity.id)
                                },
                                onMove: { newTimeOfDay in
                                    onMoveActivity(activity, newTimeOfDay)
                                }
                            )
                            .onDrag {
                                // Make activity draggable
                                NSItemProvider(object: activity.id.uuidString as NSString)
                            }
                        }
                    }
                }
            }
            .onDrop(of: ["video.item"], isTargeted: nil) { providers, _ in
                // Handle drop of video
                return false
            }
        }
    }
}

// Activity card
struct ActivityCard: View {
    let activity: TripActivity
    let onRemove: () -> Void
    let onMove: (TripActivity.TimeOfDay) -> Void
    @State private var showingOptions = false
    
    var body: some View {
        HStack {
            // Activity icon based on source
            Image(systemName: sourceIcon(for: activity.sourceType))
                .foregroundColor(.teal)
                .frame(width: 30)
            
            // Activity details
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.subheadline)
                    .lineLimit(1)
                
                if !activity.location.isEmpty {
                    Text(activity.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Options button
            Button(action: {
                showingOptions = true
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .padding(8)
            }
            .actionSheet(isPresented: $showingOptions) {
                ActionSheet(
                    title: Text("Activity Options"),
                    buttons: [
                        .default(Text("Move to Morning")) {
                            if activity.timeOfDay != .morning {
                                onMove(.morning)
                            }
                        },
                        .default(Text("Move to Afternoon")) {
                            if activity.timeOfDay != .afternoon {
                                onMove(.afternoon)
                            }
                        },
                        .default(Text("Move to Evening")) {
                            if activity.timeOfDay != .evening {
                                onMove(.evening)
                            }
                        },
                        .destructive(Text("Remove")) {
                            onRemove()
                        },
                        .cancel()
                    ]
                )
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    // Get icon based on source type
    private func sourceIcon(for source: String) -> String {
        switch source.lowercased() {
        case "instagram":
            return "camera"
        case "tiktok":
            return "music.note"
        case "youtube":
            return "play.rectangle"
        default:
            return "film"
        }
    }
}

// Video picker for selecting videos to add to a trip
struct VideoPicker: View {
    @ObservedObject var videoService: VideoService
    let onSelectVideos: ([Video]) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedVideos = Set<Video>()
    @State private var searchText = ""
    @State private var selectedTags = Set<String>()
    
    private var filteredVideos: [Video] {
        videoService.getFilteredVideos(searchText: searchText, selectedTags: selectedTags)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search videos", text: $searchText)
                        .font(.body)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 4)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Video.popularFilters, id: \.self) { filter in
                            FilterChipView(
                                title: filter,
                                isSelected: selectedTags.contains(filter),
                                action: {
                                    toggleTag(filter)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 16)
                
                // Videos grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(filteredVideos) { video in
                            VideoPickerItem(
                                video: video,
                                isSelected: selectedVideos.contains(video),
                                onToggle: {
                                    toggleVideoSelection(video)
                                }
                            )
                        }
                    }
                    .padding()
                }
                
                // Bottom bar with add button
                VStack {
                    Button(action: {
                        onSelectVideos(Array(selectedVideos))
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Add \(selectedVideos.count) \(selectedVideos.count == 1 ? "Video" : "Videos")")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedVideos.isEmpty ? Color.gray : Color.teal)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(selectedVideos.isEmpty)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitle("Select Videos", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // Toggle tag selection
    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    // Toggle video selection
    private func toggleVideoSelection(_ video: Video) {
        if selectedVideos.contains(video) {
            selectedVideos.remove(video)
        } else {
            selectedVideos.insert(video)
        }
    }
}

// Video item in the picker
struct VideoPickerItem: View {
    let video: Video
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 0) {
                // Video thumbnail
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.8))
                        )
                        .clipped()
                    
                    // Source badge
                    HStack(spacing: 4) {
                        Image(systemName: video.source.icon)
                            .font(.system(size: 10))
                        
                        Text(video.source.rawValue)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Capsule())
                    .padding(8)
                }
                
                // Title
                Text(video.title)
                    .font(.subheadline)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                
                // Location if available
                if let location = video.location {
                    Text("\(location.city), \(location.country)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.teal : Color.clear, lineWidth: 2)
            )
            .overlay(
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .teal : .gray)
                    .padding(8),
                alignment: .topTrailing
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DragDropPlannerView(tripDetailViewModel: TripDetailViewModel(trip: Trip.upcomingSamples[0]))
}
