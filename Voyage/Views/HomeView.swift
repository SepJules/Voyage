//
//  HomeView.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = TripViewModel()
    @State private var showingAddTripView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Title
                    Text("Trips")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    
                    // Upcoming Trips Section
                    Text("Upcoming trips")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    
                    if Trip.upcomingSamples.isEmpty {
                        emptyTripView(message: "No upcoming trips planned yet")
                    } else {
                        VStack(spacing: 16) {
                            ForEach(Trip.upcomingSamples) { trip in
                                TripCardView(trip: trip)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Completed Trips Section
                    Text("Completed trips")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 24)
                        .padding(.bottom, 8)
                    
                    if Trip.completedSamples.isEmpty {
                        emptyTripView(message: "No completed trips")
                    } else {
                        VStack(spacing: 16) {
                            ForEach(Trip.completedSamples) { trip in
                                TripCardView(trip: trip)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 80) // Space for tab bar
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddTripView) {
                AddTripView(viewModel: viewModel)
            }
        }
    }
    
    // Empty state view
    private func emptyTripView(message: String) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "airplane")
                    .font(.system(size: 32))
                    .foregroundColor(.gray)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 40)
            Spacer()
        }
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// Airbnb-style Trip Card
struct TripCardView: View {
    let trip: Trip
    
    var body: some View {
        NavigationLink(destination: TripDetailView(trip: trip)) {
            VStack(alignment: .leading, spacing: 0) {
                // Trip card header with placeholder
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 140)
                    .overlay(
                        // Status indicator (pending, confirmed, etc.)
                        VStack {
                            if !trip.isCompleted {
                                Text("Upcoming")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.teal)
                                    .cornerRadius(16)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text("Completed")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.gray)
                                    .cornerRadius(16)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Spacer()
                        }
                    )
                    .cornerRadius(12, corners: [.topLeft, .topRight])
                
                // Trip details
                VStack(alignment: .leading, spacing: 6) {
                    // Trip name
                    Text(trip.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Trip dates
                    Text(trip.dateRangeText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Location
                    Text(trip.locationDisplayText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Separator line
                    Divider()
                        .padding(.vertical, 12)
                    
                    // Collaborators and ideas count
                    HStack {
                        // Simplified collaborator display
                        HStack(spacing: -8) {
                            // Show up to 3 placeholder circles or 1 if no collaborators
                            if trip.collaborators.isEmpty {
                                // Single placeholder
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.gray)
                                    )
                            } else {
                                // Show placeholder circles for collaborators (up to 3)
                                ForEach(0..<min(trip.collaborators.count, 3), id: \.self) { _ in
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
                        }
                        
                        Spacer()
                        
                        // Ideas count
                        HStack(spacing: 4) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.yellow)
                            
                            Text("\(trip.ideasCount) ideas")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
} 