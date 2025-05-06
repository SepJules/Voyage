//
//  IdeasView.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import SwiftUI

struct IdeasView: View {
    @State private var showAllIdeas = false
    @State private var searchText = ""
    @State private var selectedFilters = Set<String>()
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    private let singleColumn = [
        GridItem(.flexible(), spacing: 16)
    ]
    
    private let ideas = Idea.samples
    private let boards = Board.samples
    private let filterTags = Idea.popularFilters
    
    private let activityFilters = ["Food", "Nature", "Culture", "Adventure", "Shopping"]
    private let cityFilters = ["Tokyo", "Paris", "Rome"]
    private let countryFilters = ["Japan", "France", "Italy"]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Title and toggle
                HStack {
                    Text("Ideas")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
                
                // Toggle between Boards and All Ideas
                HStack {
                    Button(action: {
                        withAnimation {
                            showAllIdeas = false
                        }
                    }) {
                        Text("Boards")
                            .font(.headline)
                            .foregroundColor(showAllIdeas ? .secondary : .primary)
                            .padding(.bottom, 8)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(showAllIdeas ? .clear : .teal)
                                    .offset(y: 4),
                                alignment: .bottom
                            )
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        withAnimation {
                            showAllIdeas = true
                        }
                    }) {
                        Text("All Ideas")
                            .font(.headline)
                            .foregroundColor(showAllIdeas ? .primary : .secondary)
                            .padding(.bottom, 8)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(showAllIdeas ? .teal : .clear)
                                    .offset(y: 4),
                                alignment: .bottom
                            )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                // Content based on toggle
                if showAllIdeas {
                    allIdeasView
                } else {
                    boardsView
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // All Ideas View (with search bar, filter chips and two-column layout)
    private var allIdeasView: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search your saved ideas", text: $searchText)
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
            
            // Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Activity Type filters
                    ForEach(activityFilters, id: \.self) { filter in
                        FilterChipView(
                            title: filter,
                            isSelected: selectedFilters.contains(filter),
                            action: {
                                toggleFilter(filter)
                            }
                        )
                    }
                    
                    // City filters
                    ForEach(cityFilters, id: \.self) { filter in
                        FilterChipView(
                            title: filter,
                            isSelected: selectedFilters.contains(filter),
                            action: {
                                toggleFilter(filter)
                            }
                        )
                    }
                    
                    // Country filters
                    ForEach(countryFilters, id: \.self) { filter in
                        FilterChipView(
                            title: filter,
                            isSelected: selectedFilters.contains(filter),
                            action: {
                                toggleFilter(filter)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
            
            // Ideas Grid (two-column layout)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(ideas) { idea in
                        EnhancedIdeaCardView(
                            idea: idea,
                            isSelected: false,
                            isMultiSelectMode: false,
                            onTap: {
                                // Navigate to idea detail
                            },
                            onLongPress: {
                                // Long press not implemented in this view yet
                            },
                            onOptionsTap: {
                                // Options menu
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
    
    // Toggle filter selection
    private func toggleFilter(_ filter: String) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }
    
    // Boards View - single column
    private var boardsView: some View {
        ScrollView {
            LazyVGrid(columns: singleColumn, spacing: 20) {
                // Regular board cards
                ForEach(boards) { board in
                    AirbnbBoardView(board: board)
                }
                
                // "Create New Trip" card
                CreateNewBoardView()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 80) // Space for the tab bar and floating button
        }
    }
}

// ReciMe-style card view for ideas
struct ReciMeIdeaCardView: View {
    let idea: Idea
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image with source badge
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: idea.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                }
                .frame(height: 140)
                .clipped()
                
                // Source badge
                HStack(spacing: 4) {
                    Image(systemName: "link")
                        .font(.system(size: 10))
                    
                    Text(idea.source)
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
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(idea.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                // Subtitle (location and activity type)
                Text("\(idea.activityType) · \(idea.city), \(idea.country)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(10)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

// Updated Filter Chip View for the filter row
struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption2)
                .fontWeight(isSelected ? .medium : .regular)
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.teal : Color(.systemGray5))
                .clipShape(Capsule())
        }
    }
}

// Airbnb-inspired Board View - without background
struct AirbnbBoardView: View {
    let board: Board
    
    var body: some View {
        NavigationLink(destination: BoardDetailView(board: board)) {
            VStack(alignment: .leading, spacing: 8) {
                // Image grid
                ZStack(alignment: .bottomTrailing) {
                    ImageCollageView(imageURLs: board.previewImageURLs)
                        .aspectRatio(1.5, contentMode: .fill)
                        .frame(height: 200)
                        .cornerRadius(12)
                    
                    // Collaborator avatars
                    HStack(spacing: -8) {
                        ForEach(board.collaboratorImageURLs, id: \.self) { url in
                            AsyncImage(url: URL(string: url)) { phase in
                                switch phase {
                                case .empty:
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(Circle())
                                case .failure:
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                @unknown default:
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                }
                            }
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                        }
                    }
                    .padding(8)
                }
                
                // Title and count
                VStack(alignment: .leading, spacing: 3) {
                    Text(board.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(board.ideasCount) ideas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)
                .padding(.top, 8)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Create New Trip View - without background
struct CreateNewBoardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Dashed border rectangle
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(Color.gray.opacity(0.3))
                    .frame(height: 200)
                
                Image(systemName: "plus.circle")
                    .font(.system(size: 32))
                    .foregroundColor(.teal)
            }
            
            // Title
            Text("Create New Trip")
                .font(.headline)
                .foregroundColor(.teal)
                .padding(.horizontal, 4)
                .padding(.top, 8)
        }
    }
}

// Image Collage View for displaying trip board previews
struct ImageCollageView: View {
    let imageURLs: [String]
    
    var body: some View {
        GeometryReader { geometry in
            let count = min(imageURLs.count, 4)
            
            Group {
                if count == 1 {
                    singleImage(geometry: geometry)
                } else if count == 2 {
                    twoImages(geometry: geometry)
                } else if count == 3 {
                    threeImages(geometry: geometry)
                } else {
                    fourImages(geometry: geometry)
                }
            }
        }
    }
    
    private func singleImage(geometry: GeometryProxy) -> some View {
        AsyncImage(url: URL(string: imageURLs[0])) { phase in
            imagePhaseView(phase)
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
    }
    
    private func twoImages(geometry: GeometryProxy) -> some View {
        HStack(spacing: 2) {
            AsyncImage(url: URL(string: imageURLs[0])) { phase in
                imagePhaseView(phase)
            }
            .frame(width: geometry.size.width / 2 - 1, height: geometry.size.height)
            
            AsyncImage(url: URL(string: imageURLs[1])) { phase in
                imagePhaseView(phase)
            }
            .frame(width: geometry.size.width / 2 - 1, height: geometry.size.height)
        }
    }
    
    private func threeImages(geometry: GeometryProxy) -> some View {
        HStack(spacing: 2) {
            AsyncImage(url: URL(string: imageURLs[0])) { phase in
                imagePhaseView(phase)
            }
            .frame(width: geometry.size.width / 2 - 1, height: geometry.size.height)
            
            VStack(spacing: 2) {
                AsyncImage(url: URL(string: imageURLs[1])) { phase in
                    imagePhaseView(phase)
                }
                .frame(width: geometry.size.width / 2 - 1, height: geometry.size.height / 2 - 1)
                
                AsyncImage(url: URL(string: imageURLs[2])) { phase in
                    imagePhaseView(phase)
                }
                .frame(width: geometry.size.width / 2 - 1, height: geometry.size.height / 2 - 1)
            }
        }
    }
    
    private func fourImages(geometry: GeometryProxy) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                AsyncImage(url: URL(string: imageURLs[0])) { phase in
                    imagePhaseView(phase)
                }
                .frame(width: geometry.size.width / 2 - 1, height: geometry.size.height / 2 - 1)
                
                AsyncImage(url: URL(string: imageURLs[1])) { phase in
                    imagePhaseView(phase)
                }
                .frame(width: geometry.size.width / 2 - 1, height: geometry.size.height / 2 - 1)
            }
            
            HStack(spacing: 2) {
                AsyncImage(url: URL(string: imageURLs[2])) { phase in
                    imagePhaseView(phase)
                }
                .frame(width: geometry.size.width / 2 - 1, height: geometry.size.height / 2 - 1)
                
                AsyncImage(url: URL(string: imageURLs[3])) { phase in
                    imagePhaseView(phase)
                }
                .frame(width: geometry.size.width / 2 - 1, height: geometry.size.height / 2 - 1)
            }
        }
    }
    
    private func imagePhaseView(_ phase: AsyncImagePhase) -> some View {
        switch phase {
        case .empty:
            return AnyView(
                ZStack {
                    Color.gray.opacity(0.2)
                    ProgressView()
                }
            )
        case .success(let image):
            return AnyView(
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )
        case .failure:
            return AnyView(
                ZStack {
                    Color.gray.opacity(0.2)
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
            )
        @unknown default:
            return AnyView(Color.gray.opacity(0.2))
        }
    }
}

// Tag View for displaying pill-style tags
struct TagView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.caption2)
            .foregroundColor(.gray)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.systemGray5))
            .clipShape(Capsule())
    }
}

#Preview {
    IdeasView()
        .accentColor(.teal)
} 