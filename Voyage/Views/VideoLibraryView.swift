//
//  VideoLibraryView.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import SwiftUI
import AVKit

struct VideoLibraryView: View {
    @StateObject private var videoService = VideoService()
    @State private var searchText = ""
    @State private var selectedTags = Set<String>()
    @State private var isMultiSelectMode = false
    @State private var selectedVideos = Set<Video>()
    @State private var showingImportOptions = false
    @State private var showingVideoDetail = false
    @State private var selectedVideo: Video?
    @State private var showingAddToTripView = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    private var filteredVideos: [Video] {
        videoService.getFilteredVideos(searchText: searchText, selectedTags: selectedTags)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Multi-select toolbar
                if isMultiSelectMode {
                    multiSelectToolbar
                } else {
                    // Title
                    Text("Videos")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                }
                
                // Search Bar
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
                .padding(.bottom, 12)
                
                // Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // Source filters
                        ForEach(VideoSource.allCases, id: \.self) { source in
                            FilterChipView(
                                title: source.rawValue,
                                isSelected: selectedTags.contains(source.rawValue),
                                action: {
                                    toggleTag(source.rawValue)
                                }
                            )
                        }
                        
                        // Popular location filters
                        ForEach(["Tokyo", "Paris", "Bali", "Rome", "New York"], id: \.self) { location in
                            FilterChipView(
                                title: location,
                                isSelected: selectedTags.contains(location),
                                action: {
                                    toggleTag(location)
                                }
                            )
                        }
                        
                        // Popular tag filters
                        ForEach(["Food", "Beach", "City", "Nature"], id: \.self) { tag in
                            FilterChipView(
                                title: tag,
                                isSelected: selectedTags.contains(tag),
                                action: {
                                    toggleTag(tag)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 16)
                
                // Select videos button - below filter pills
                if !isMultiSelectMode {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            enterSelectionMode()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle")
                                    .font(.caption)
                                
                                Text("Select")
                                    .font(.subheadline)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 12)
                }
                
                // Videos Grid
                if filteredVideos.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredVideos) { video in
                                VideoCardView(
                                    video: video,
                                    isSelected: selectedVideos.contains(video),
                                    isMultiSelectMode: isMultiSelectMode,
                                    onTap: {
                                        handleVideoTap(video)
                                    },
                                    onLongPress: {
                                        enterMultiSelectMode(with: video)
                                    },
                                    onOptionsTap: {
                                        selectedVideo = video
                                        // Show options menu
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .padding(.bottom, 80) // Space for the tab bar and floating button
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingImportOptions) {
                VideoImportView(videoService: videoService)
            }
            .sheet(isPresented: $showingVideoDetail) {
                if let video = selectedVideo {
                    VideoDetailView(video: video, videoService: videoService)
                }
            }
            .sheet(isPresented: $showingAddToTripView) {
                AddVideoToTripView(videos: Array(selectedVideos), videoService: videoService)
            }
            .overlay(
                // Floating Import Button
                Button(action: {
                    showingImportOptions = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.teal)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 100),
                alignment: .bottomTrailing
            )
        }
    }
    
    // Multi-select toolbar
    private var multiSelectToolbar: some View {
        HStack {
            Button(action: {
                isMultiSelectMode = false
                selectedVideos.removeAll()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.primary)
                    .padding(8)
            }
            
            Spacer()
            
            Text("\(selectedVideos.count) selected")
                .font(.headline)
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {
                    showingAddToTripView = true
                }) {
                    Text("Add to Trip")
                        .foregroundColor(.teal)
                }
                
                Button(action: {
                    // Delete selected videos
                    for video in selectedVideos {
                        videoService.deleteVideo(video)
                    }
                    selectedVideos.removeAll()
                    isMultiSelectMode = false
                }) {
                    Text("Delete")
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    // Empty state view
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "film")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No videos in your library")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Import videos from social media by tapping the + button")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                showingImportOptions = true
            }) {
                Text("Import Videos")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.teal)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // Toggle tag selection
    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    // Handle tapping a video card
    private func handleVideoTap(_ video: Video) {
        if isMultiSelectMode {
            toggleVideoSelection(video)
        } else {
            selectedVideo = video
            showingVideoDetail = true
        }
    }
    
    // Toggle video selection in multi-select mode
    private func toggleVideoSelection(_ video: Video) {
        if selectedVideos.contains(video) {
            selectedVideos.remove(video)
        } else {
            selectedVideos.insert(video)
        }
        
        // If no videos are selected, exit multi-select mode
        if selectedVideos.isEmpty {
            isMultiSelectMode = false
        }
    }
    
    // Enter multi-select mode with an initial selected video
    private func enterMultiSelectMode(with video: Video) {
        isMultiSelectMode = true
        selectedVideos = [video]
    }
    
    // Enter selection mode without selecting any videos
    private func enterSelectionMode() {
        isMultiSelectMode = true
        selectedVideos.removeAll()
    }
}

// Video Card View
struct VideoCardView: View {
    let video: Video
    let isSelected: Bool
    let isMultiSelectMode: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    let onOptionsTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Video thumbnail with play icon and source badge
                ZStack(alignment: .bottomLeading) {
                    // Placeholder for video thumbnail
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 140)
                        .overlay(
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 40))
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
                
                // Content area with padding
                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    Text(video.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    // Location if available
                    if let location = video.location {
                        Text("\(location.city), \(location.country)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    // Tags row
                    if !video.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(video.tags.prefix(3), id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption2)
                                        .foregroundColor(.teal)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.teal.opacity(0.1))
                                        .cornerRadius(4)
                                }
                                
                                if video.tags.count > 3 {
                                    Text("+\(video.tags.count - 3)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    // Trip count if associated with trips
                    if !video.tripIDs.isEmpty {
                        HStack {
                            if video.tripIDs.count == 1 {
                                Text("In 1 Trip")
                                    .font(.caption2)
                                    .foregroundColor(.teal)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.teal.opacity(0.1))
                                    .cornerRadius(4)
                            } else {
                                Text("In \(video.tripIDs.count) Trips")
                                    .font(.caption2)
                                    .foregroundColor(.teal)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.teal.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            
                            Spacer()
                            
                            // Options button (three dots)
                            Button(action: onOptionsTap) {
                                Image(systemName: "ellipsis")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(4)
                            }
                        }
                    } else {
                        // Just the options button when no trips
                        HStack {
                            Spacer()
                            Button(action: onOptionsTap) {
                                Image(systemName: "ellipsis")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(4)
                            }
                        }
                    }
                }
                .padding(10)
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.teal : Color.clear, lineWidth: 2)
            )
            .opacity(isMultiSelectMode && !isSelected ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: {
                // Add to trip action
            }) {
                Label("Add to Trip", systemImage: "airplane")
            }
            
            Button(action: {
                // Share action
            }) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            
            Button(action: {
                // Delete action
            }) {
                Label("Delete", systemImage: "trash")
                    .foregroundColor(.red)
            }
        }
        .onLongPressGesture {
            onLongPress()
        }
    }
}

// Placeholder for VideoDetailView
struct VideoDetailView: View {
    let video: Video
    let videoService: VideoService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Video player
                    ZStack {
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 220)
                            .overlay(
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.8))
                            )
                    }
                    
                    // Title
                    Text(video.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Source and date
                    HStack {
                        Label(video.source.rawValue, systemImage: video.source.icon)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(video.dateAdded, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Location
                    if let location = video.location {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.teal)
                            
                            Text("\(location.city), \(location.country)")
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Tags
                    if !video.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(video.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .foregroundColor(.teal)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.teal.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Divider()
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Action buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            // Add to trip
                        }) {
                            VStack {
                                Image(systemName: "airplane")
                                    .font(.system(size: 24))
                                Text("Add to Trip")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {
                            videoService.toggleFavorite(for: video)
                        }) {
                            VStack {
                                Image(systemName: video.isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 24))
                                    .foregroundColor(video.isFavorite ? .red : .primary)
                                Text("Favorite")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {
                            // Share
                        }) {
                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 24))
                                Text("Share")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitle("Video Details", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                // Edit video details
            }) {
                Text("Edit")
            })
        }
    }
}

// Placeholder for VideoImportView
struct VideoImportView: View {
    let videoService: VideoService
    @Environment(\.presentationMode) var presentationMode
    @State private var importURL = ""
    @State private var selectedSource: VideoSource = .instagram
    @State private var isImporting = false
    @State private var importError: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header image
                Image(systemName: "film")
                    .font(.system(size: 60))
                    .foregroundColor(.teal)
                    .padding(.top, 20)
                
                Text("Import Videos")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Import videos from social media platforms")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Source selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Source")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        ForEach(VideoSource.allCases, id: \.self) { source in
                            Button(action: {
                                selectedSource = source
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: source.icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedSource == source ? .white : .teal)
                                    
                                    Text(source.rawValue)
                                        .font(.caption)
                                        .foregroundColor(selectedSource == source ? .white : .teal)
                                }
                                .frame(width: 70, height: 70)
                                .background(selectedSource == source ? Color.teal : Color.teal.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // URL input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Video URL")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextField("Paste video URL here", text: $importURL)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Error message if any
                if let error = importError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                // Import button
                Button(action: {
                    importVideo()
                }) {
                    HStack {
                        Text("Import Video")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if isImporting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.leading, 5)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(importURL.isEmpty ? Color.gray : Color.teal)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .disabled(importURL.isEmpty || isImporting)
                .padding(.top, 20)
                
                Spacer()
                
                // Note about share extension
                Text("Tip: You can also use the iOS share sheet in social media apps to import videos directly")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func importVideo() {
        guard let url = URL(string: importURL) else {
            importError = "Invalid URL format"
            return
        }
        
        isImporting = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            videoService.handleImportedVideoURL(url, source: selectedSource) { result in
                isImporting = false
                
                switch result {
                case .success(_):
                    // Successfully imported
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    importError = error.localizedDescription
                }
            }
        }
    }
}

// Placeholder for AddVideoToTripView
struct AddVideoToTripView: View {
    let videos: [Video]
    let videoService: VideoService
    @StateObject private var tripViewModel = TripViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTripId: UUID?
    
    var body: some View {
        NavigationView {
            VStack {
                if tripViewModel.upcomingTrips.isEmpty {
                    // No trips available
                    VStack(spacing: 20) {
                        Image(systemName: "airplane")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No upcoming trips")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Create a trip first to add videos to it")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            // Navigate to create trip
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Create Trip")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.teal)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.vertical, 60)
                } else {
                    // List of trips
                    List {
                        ForEach(tripViewModel.upcomingTrips) { trip in
                            Button(action: {
                                selectedTripId = trip.id
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(trip.name)
                                            .font(.headline)
                                        
                                        Text(trip.dateRangeText)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedTripId == trip.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.teal)
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Add button
                    Button(action: {
                        addVideosToTrip()
                    }) {
                        Text("Add \(videos.count) \(videos.count == 1 ? "Video" : "Videos") to Trip")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedTripId == nil ? Color.gray : Color.teal)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                    .disabled(selectedTripId == nil)
                }
            }
            .navigationBarTitle("Add to Trip", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func addVideosToTrip() {
        guard let tripId = selectedTripId else { return }
        
        for video in videos {
            videoService.associateVideoWithTrip(video, tripId: tripId)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    VideoLibraryView()
}
