//
//  VideoService.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import MobileCoreServices

class VideoService: ObservableObject {
    private let videosKey = "savedVideos"
    
    @Published var videos: [Video] = []
    @Published var isImporting = false
    
    init() {
        loadVideos()
        
        // If no videos are loaded, use sample data
        if videos.isEmpty {
            videos = Video.samples
        }
    }
    
    // MARK: - Data Persistence
    
    func saveVideos() {
        if let encoded = try? JSONEncoder().encode(videos) {
            UserDefaults.standard.set(encoded, forKey: videosKey)
        }
    }
    
    func loadVideos() {
        if let data = UserDefaults.standard.data(forKey: videosKey),
           let decoded = try? JSONDecoder().decode([Video].self, from: data) {
            videos = decoded
        }
    }
    
    // MARK: - Video Management
    
    func addVideo(_ video: Video) {
        videos.append(video)
        saveVideos()
    }
    
    func updateVideo(_ video: Video) {
        if let index = videos.firstIndex(where: { $0.id == video.id }) {
            videos[index] = video
            saveVideos()
        }
    }
    
    func deleteVideo(_ video: Video) {
        videos.removeAll { $0.id == video.id }
        saveVideos()
    }
    
    func toggleFavorite(for video: Video) {
        if let index = videos.firstIndex(where: { $0.id == video.id }) {
            videos[index].isFavorite.toggle()
            saveVideos()
        }
    }
    
    // MARK: - Video Import
    
    // Handle video import from share extension
    func handleImportedVideoURL(_ url: URL, source: VideoSource, completion: @escaping (Result<Video, Error>) -> Void) {
        // In a real app, this would download the video, extract metadata, generate thumbnail, etc.
        // For this demo, we'll create a placeholder video
        
        let videoTitle = extractTitleFromURL(url)
        
        // Create a new video
        let newVideo = Video(
            title: videoTitle,
            source: source,
            url: url,
            dateAdded: Date()
        )
        
        // Add the video to our collection
        addVideo(newVideo)
        
        // Return success
        completion(.success(newVideo))
    }
    
    // Extract a title from the URL
    private func extractTitleFromURL(_ url: URL) -> String {
        // In a real app, this would parse the URL to extract meaningful information
        // For this demo, we'll just use the last path component
        let lastPathComponent = url.lastPathComponent
        
        // Remove file extension if present
        if let range = lastPathComponent.range(of: ".", options: .backwards) {
            return String(lastPathComponent[..<range.lowerBound])
                .replacingOccurrences(of: "-", with: " ")
                .replacingOccurrences(of: "_", with: " ")
        }
        
        return lastPathComponent
    }
    
    // MARK: - Video Filtering
    
    func getFilteredVideos(searchText: String, selectedTags: Set<String>) -> [Video] {
        if searchText.isEmpty && selectedTags.isEmpty {
            return videos
        }
        
        return videos.filter { video in
            // Filter by search text
            let matchesSearch = searchText.isEmpty || 
                video.title.localizedCaseInsensitiveContains(searchText) ||
                (video.location?.city.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (video.location?.country.localizedCaseInsensitiveContains(searchText) ?? false)
            
            // Filter by tags
            let matchesTags = selectedTags.isEmpty || 
                !Set(video.tags).isDisjoint(with: selectedTags) ||
                selectedTags.contains(video.source.rawValue) ||
                (video.location != nil && (
                    selectedTags.contains(video.location!.city) ||
                    selectedTags.contains(video.location!.country)
                ))
            
            return matchesSearch && matchesTags
        }
    }
    
    // MARK: - Trip Association
    
    func associateVideoWithTrip(_ video: Video, tripId: UUID) {
        if let index = videos.firstIndex(where: { $0.id == video.id }) {
            if !videos[index].tripIDs.contains(tripId) {
                videos[index].tripIDs.append(tripId)
                saveVideos()
            }
        }
    }
    
    func removeVideoFromTrip(_ video: Video, tripId: UUID) {
        if let index = videos.firstIndex(where: { $0.id == video.id }) {
            videos[index].tripIDs.removeAll { $0 == tripId }
            saveVideos()
        }
    }
    
    func getVideosForTrip(tripId: UUID) -> [Video] {
        return videos.filter { $0.tripIDs.contains(tripId) }
    }
}
