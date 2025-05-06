//
//  EditTripView.swift
//  Voyage
//
//  Created by Julian Sun Ou on 6/5/2025.
//

import SwiftUI

struct EditTripView: View {
    var trip: Trip
    var onSave: (Trip) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String
    @State private var destination: String
    @State private var city: String = ""
    @State private var country: String = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var notes: String
    @State private var showingAddLocation = false
    
    // Lists for multiple cities and countries
    @State private var cities: [String]
    @State private var countries: [String]
    
    init(trip: Trip, onSave: @escaping (Trip) -> Void) {
        self.trip = trip
        self.onSave = onSave
        
        _name = State(initialValue: trip.name)
        _destination = State(initialValue: trip.destination)
        _startDate = State(initialValue: trip.startDate)
        _endDate = State(initialValue: trip.endDate)
        _notes = State(initialValue: trip.notes)
        _cities = State(initialValue: trip.cities)
        _countries = State(initialValue: trip.countries)
    }
    
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
            .navigationTitle("Edit Trip")
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
        var updatedTrip = trip
        updatedTrip.name = name
        updatedTrip.destination = destination
        updatedTrip.startDate = startDate
        updatedTrip.endDate = endDate
        updatedTrip.notes = notes
        updatedTrip.cities = cities
        updatedTrip.countries = countries
        
        onSave(updatedTrip)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    EditTripView(trip: Trip.upcomingSamples[0]) { _ in }
} 