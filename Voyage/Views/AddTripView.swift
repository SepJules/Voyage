//
//  AddTripView.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import SwiftUI

struct AddTripView: View {
    @ObservedObject var viewModel: TripViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var destination = ""
    @State private var city = ""
    @State private var country = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(7*24*60*60)
    @State private var notes = ""
    @State private var showingAddLocation = false
    
    // Lists for multiple cities and countries
    @State private var cities: [String] = []
    @State private var countries: [String] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Trip Details")) {
                    TextField("Trip Name", text: $name)
                    TextField("Destination", text: $destination)
                }
                
                Section(header: Text("Locations")) {
                    if cities.isEmpty && countries.isEmpty {
                        Text("No locations added yet")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(0..<max(cities.count, countries.count), id: \.self) { index in
                            if index < cities.count && index < countries.count {
                                HStack {
                                    Text(cities[index])
                                    Spacer()
                                    Text(countries[index])
                                        .foregroundColor(.secondary)
                                }
                            } else if index < cities.count {
                                Text(cities[index])
                            } else if index < countries.count {
                                Text(countries[index])
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: deleteLocation)
                    }
                    
                    Button("Add Location") {
                        showingAddLocation = true
                    }
                }
                
                Section(header: Text("Dates")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTrip()
                    }
                    .disabled(name.isEmpty || destination.isEmpty || cities.isEmpty || countries.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddLocation) {
                AddLocationView(city: $city, country: $country, onAdd: {
                    if !city.isEmpty && !country.isEmpty {
                        cities.append(city)
                        countries.append(country)
                        city = ""
                        country = ""
                    }
                    showingAddLocation = false
                }, onCancel: {
                    showingAddLocation = false
                })
            }
        }
    }
    
    private func deleteLocation(at offsets: IndexSet) {
        cities.remove(atOffsets: offsets)
        countries.remove(atOffsets: offsets)
    }
    
    private func saveTrip() {
        let newTrip = Trip(
            name: name,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            activities: [],
            notes: notes,
            cities: cities,
            countries: countries
        )
        
        viewModel.addTrip(newTrip)
        presentationMode.wrappedValue.dismiss()
    }
}

// View to add a new location
struct AddLocationView: View {
    @Binding var city: String
    @Binding var country: String
    var onAdd: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Location Details")) {
                    TextField("City", text: $city)
                    TextField("Country", text: $country)
                }
            }
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        onAdd()
                    }
                    .disabled(city.isEmpty || country.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddTripView(viewModel: TripViewModel())
} 