//
//  MainTabView.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showActionModal = false
    @State private var showImportModal = false
    @State private var showingAddTrip = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            ZStack {
                if selectedTab == 0 {
                    HomeView()
                } else if selectedTab == 2 {
                    IdeasView()
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 49) // Reserve space for tab bar
            }
            
            // Action Sheet Modal (for main options)
            if showActionModal {
                ActionSheetView(
                    isPresented: $showActionModal,
                    showImportModal: $showImportModal,
                    showingAddTrip: $showingAddTrip
                )
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: showActionModal)
                .zIndex(1)
            }
            
            // Bottom sheet modal (for idea import options)
            if showImportModal {
                BottomSheetView(isPresented: $showImportModal)
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: showImportModal)
                    .zIndex(1)
            }
            
            // Custom tab bar
            VStack(spacing: 0) {
                TabBarView(selectedTab: $selectedTab, showModal: $showActionModal)
                    .ignoresSafeArea(.keyboard)
            }
        }
        .sheet(isPresented: $showingAddTrip) {
            AddTripView(viewModel: TripViewModel())
        }
    }
}

// Custom Tab Bar View
struct TabBarView: View {
    @Binding var selectedTab: Int
    @Binding var showModal: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Bar Background
            HStack {
                Spacer()
                
                // Trips Tab
                Button {
                    selectedTab = 0
                } label: {
                    VStack(spacing: 2) {
                        Spacer().frame(height: 6)
                        Image(systemName: "suitcase.fill")
                            .font(.system(size: 24))
                        Text("Trips")
                            .font(.caption2)
                    }
                    .foregroundColor(selectedTab == 0 ? .teal : .gray)
                    .padding(.bottom, 4) // Shift down slightly
                }
                
                Spacer()
                
                // Center space for add button
                Spacer()
                    .frame(width: 60)
                
                Spacer()
                
                // Ideas Tab
                Button {
                    selectedTab = 2
                } label: {
                    VStack(spacing: 2) {
                        Spacer().frame(height: 6)
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 24))
                        Text("Ideas")
                            .font(.caption2)
                    }
                    .foregroundColor(selectedTab == 2 ? .teal : .gray)
                    .padding(.bottom, 4) // Shift down slightly
                }
                
                Spacer()
            }
            .frame(height: 53) // Slightly taller to accommodate the padding
            .background(
                Rectangle()
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: -2)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .overlay(
            // Floating Action Button
            Button {
                withAnimation {
                    showModal = true
                }
            } label: {
                ZStack {
                    Circle()
                        .foregroundColor(.teal)
                        .frame(width: 50, height: 50) // Smaller button
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold)) // Smaller icon
                        .foregroundColor(.white)
                }
            }
            .offset(y: -25) // Shifted down slightly
            ,
            alignment: .center
        )
    }
}

// Action Sheet View - For Main Options (Create Trip or Add Idea)
struct ActionSheetView: View {
    @Binding var isPresented: Bool
    @Binding var showImportModal: Bool
    @Binding var showingAddTrip: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Semi-transparent background
            if isPresented {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }
            }
            
            // Sheet content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("What would you like to add?")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                // Main option buttons
                VStack(spacing: 16) {
                    // Create Trip Button
                    Button {
                        withAnimation {
                            isPresented = false
                            // Small delay to prevent UI glitch
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showingAddTrip = true
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "suitcase.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                            
                            Text("Create New Trip")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.teal)
                        .cornerRadius(12)
                    }
                    
                    // Add Idea Button
                    Button {
                        withAnimation {
                            isPresented = false
                            // Show the idea import options
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showImportModal = true
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                            
                            Text("Add Idea")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.teal)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: 32)
            }
            .background(
                Color(.systemBackground)
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -5)
            )
            .frame(height: 200)
            .offset(y: isPresented ? 0 : 300)
        }
    }
}

// Bottom Sheet View - For Idea Import Options
struct BottomSheetView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Semi-transparent background
            if isPresented {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }
            }
            
            // Sheet content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Add idea from")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                // Option buttons in grid
                HStack(spacing: 16) {
                    // Browser
                    ImportOptionButton(
                        icon: "safari",
                        title: "Browser",
                        iconColor: .teal
                    )
                    
                    // Camera
                    ImportOptionButton(
                        icon: "camera",
                        title: "Camera",
                        iconColor: .teal
                    )
                    
                    // Paste text
                    ImportOptionButton(
                        icon: "text.justify",
                        title: "Paste Text",
                        iconColor: .teal
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
                
                // Divider with OR text
                HStack {
                    VStack { Divider() }.padding(.horizontal, 8)
                    Text("or").font(.subheadline).foregroundColor(.secondary)
                    VStack { Divider() }.padding(.horizontal, 8)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
                
                // Manually add idea
                Button {
                    withAnimation {
                        isPresented = false
                    }
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                        
                        Text("Manually add idea")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer()
                    .frame(height: 32)
            }
            .background(
                Color(.systemBackground)
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -5)
            )
            .frame(height: 300)
            .offset(y: isPresented ? 0 : 300)
        }
    }
}

// Import option button
struct ImportOptionButton: View {
    let icon: String
    let title: String
    let iconColor: Color
    
    var body: some View {
        Button {
            // Import action would go here
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.teal)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.teal.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    MainTabView()
        .accentColor(.teal)
        .edgesIgnoringSafeArea(.bottom)
} 