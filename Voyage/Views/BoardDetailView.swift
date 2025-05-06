//
//  BoardDetailView.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import SwiftUI

struct BoardDetailView: View {
    let board: Board
    
    @State private var searchText = ""
    @State private var selectedFilters = Set<String>()
    @State private var isMultiSelectMode = false
    @State private var selectedIdeas = Set<Idea>()
    @State private var showingBoardOptions = false
    @State private var showingAddToTripView = false
    @State private var showingDeleteConfirmation = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // Filter ideas based on search text and selected filters
    private var filteredIdeas: [Idea] {
        let boardIdeas = Board.ideasFor(boardID: board.id)
        
        // If no filters are applied, just filter by search text
        if selectedFilters.isEmpty && searchText.isEmpty {
            return boardIdeas
        }
        
        return boardIdeas.filter { idea in
            // First filter by text search if needed
            let matchesSearch = searchText.isEmpty || 
                idea.title.localizedCaseInsensitiveContains(searchText) ||
                idea.city.localizedCaseInsensitiveContains(searchText) ||
                idea.country.localizedCaseInsensitiveContains(searchText)
            
            // Then apply tag filters if any are selected
            let matchesFilters = selectedFilters.isEmpty || 
                selectedFilters.contains(idea.activityType) ||
                selectedFilters.contains(idea.city) ||
                selectedFilters.contains(idea.country)
            
            return matchesSearch && matchesFilters
        }
    }
    
    // Get unique filter tags from ideas in this board
    private var availableFilterTags: [String] {
        let boardIdeas = Board.ideasFor(boardID: board.id)
        var tags = Set<String>()
        
        // Collect activity types, cities, and countries
        for idea in boardIdeas {
            tags.insert(idea.activityType)
            tags.insert(idea.city)
            tags.insert(idea.country)
        }
        
        return Array(tags).sorted()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Multi-select mode top bar
            if isMultiSelectMode {
                multiSelectToolbar
            }
            
            // Title
            if !isMultiSelectMode {
                HStack {
                    Text(board.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
                        showingBoardOptions = true
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.title2)
                            .padding(8)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            
            // Collaborators row
            HStack(spacing: 12) {
                // Collaborator avatars with count
                ZStack(alignment: .trailing) {
                    HStack(spacing: -8) {
                        ForEach(board.collaboratorImageURLs.prefix(3), id: \.self) { _ in
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                    }
                    
                    // Show count if more than 3 collaborators
                    if board.collaboratorImageURLs.count > 3 {
                        Text("+\(board.collaboratorImageURLs.count - 3)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Color.teal)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: 4)
                    }
                }
                
                Spacer()
                
                // Add collaborator button
                Button(action: {
                    // Action to add collaborators
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.badge.plus")
                            .font(.caption)
                        
                        Text("Add")
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
            
            // Main content area (search, filters, ideas)
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search this board", text: $searchText)
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
                        ForEach(availableFilterTags, id: \.self) { filter in
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
                .padding(.bottom, 8)
                
                // Select ideas button - below filter pills
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
                
                // Ideas Grid (two-column layout)
                ScrollView {
                    if filteredIdeas.isEmpty {
                        emptyStateView
                    } else {
                        VStack(spacing: 0) {
                            // Selection hint when in multi-select mode
                            if isMultiSelectMode {
                                ZStack {
                                    Color(.systemGray6)
                                        .opacity(0.7)
                                    
                                    HStack {
                                        Spacer()
                                        
                                        Button(action: {
                                            selectAllIdeas()
                                        }) {
                                            Text("Select All")
                                                .font(.subheadline)
                                                .foregroundColor(.teal)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 6)
                                }
                                .frame(height: 36)
                                .padding(.bottom, 8)
                            }
                            
                            // Ideas grid
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(filteredIdeas) { idea in
                                    EnhancedIdeaCardView(
                                        idea: idea,
                                        isSelected: selectedIdeas.contains(idea),
                                        isMultiSelectMode: isMultiSelectMode,
                                        onTap: {
                                            handleIdeaTap(idea)
                                        },
                                        onLongPress: {
                                            enterMultiSelectMode(with: idea)
                                        },
                                        onOptionsTap: {
                                            // Show options menu for single idea
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.bottom, 80) // Space for the tab bar and floating button
            }
        }
        .navigationBarHidden(true)
        .overlay(
            // Floating Add Idea Button
            Button(action: {
                // Action to add new idea to board
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
        .actionSheet(isPresented: $showingBoardOptions) {
            ActionSheet(
                title: Text("Board Options"),
                message: Text("Manage your board"),
                buttons: [
                    .default(Text("Rename Board")) {
                        // Rename board action
                    },
                    .default(Text("Add Collaborators")) {
                        // Add collaborators action
                    },
                    .destructive(Text("Delete Board")) {
                        showingDeleteConfirmation = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingAddToTripView) {
            // View to add selected ideas to a trip
            Text("Add to Trip View")
                .navigationTitle("Select Trip")
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete Board"),
                message: Text("Are you sure you want to delete this board? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    // Delete board action
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // Multi-select toolbar
    private var multiSelectToolbar: some View {
        HStack {
            Button(action: {
                isMultiSelectMode = false
                selectedIdeas.removeAll()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.primary)
                    .padding(8)
            }
            
            Spacer()
            
            Text("\(selectedIdeas.count) selected")
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
                    // Delete selected ideas
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
            Image(systemName: "lightbulb")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No ideas in this board yet")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Add your first idea by tapping the + button")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // Toggle filter selection
    private func toggleFilter(_ filter: String) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }
    
    // Handle tapping an idea card
    private func handleIdeaTap(_ idea: Idea) {
        if isMultiSelectMode {
            toggleIdeaSelection(idea)
        } else {
            // Navigate to idea detail view
        }
    }
    
    // Toggle idea selection in multi-select mode
    private func toggleIdeaSelection(_ idea: Idea) {
        if selectedIdeas.contains(idea) {
            selectedIdeas.remove(idea)
        } else {
            selectedIdeas.insert(idea)
        }
        
        // If no ideas are selected, exit multi-select mode
        if selectedIdeas.isEmpty {
            isMultiSelectMode = false
        }
    }
    
    // Enter multi-select mode with an initial selected idea
    private func enterMultiSelectMode(with idea: Idea) {
        isMultiSelectMode = true
        selectedIdeas = [idea]
    }
    
    // Enter selection mode without selecting any ideas
    private func enterSelectionMode() {
        isMultiSelectMode = true
        selectedIdeas.removeAll()
    }
    
    // Select all displayed ideas
    private func selectAllIdeas() {
        selectedIdeas = Set(filteredIdeas)
    }
}

// Enhanced Idea Card View with selection state and trip tags
struct EnhancedIdeaCardView: View {
    let idea: Idea
    let isSelected: Bool
    let isMultiSelectMode: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    let onOptionsTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Image with source badge
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 140)
                        .overlay(
                            ProgressView()
                        )
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
                VStack(alignment: .leading, spacing: 6) {
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
                    
                    // Trip tag (if idea is part of trips)
                    if idea.tripCount > 0 {
                        HStack {
                            if idea.tripCount == 1 {
                                Text("In: Trip")
                                    .font(.caption2)
                                    .foregroundColor(.teal)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.teal.opacity(0.1))
                                    .cornerRadius(4)
                            } else {
                                Text("In: \(idea.tripCount) Trips")
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
                // Move to another board
            }) {
                Label("Move to Another Board", systemImage: "folder")
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

#Preview {
    NavigationView {
        BoardDetailView(board: Board.samples[0])
    }
} 