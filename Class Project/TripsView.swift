//
//  TripsView.swift
//  Class Project
//
//  Created by Archit Singh on 10/22/23.
//

import SwiftUI

struct TripsView: View {
    @ObservedObject var viewModel = TripViewModel()
    
    @State private var showingAddTrip = false
    
    var body: some View {
           NavigationView {
               List {
                   ForEach(viewModel.trips) { trip in
                       NavigationLink(destination: TripDetailView(trip: trip)) {
                           VStack(alignment: .leading) {
                               Text(trip.destination)
                                   .font(.headline)
                               Text("\(trip.startDate, formatter: DateFormatter.shortDate) - \(trip.endDate, formatter: DateFormatter.shortDate)")
                                   .font(.subheadline)
                                   .foregroundColor(.gray)
                           }
                       }
                   }
                   .onDelete(perform: viewModel.removeTrip)
               }
               .navigationTitle("My Trips")
               .navigationBarItems(
                   leading: EditButton(),
                   trailing: Button(action: { showingAddTrip = true }) {
                       Image(systemName: "plus")
                   }
               )
           }
           .sheet(isPresented: $showingAddTrip) {
               AddTripView(viewModel: viewModel)
           }
       }
}

struct TripDetailView: View {
    var trip: Trip
    
    var body: some View {
        VStack {
            Text(trip.destination)
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Start Date:")
                    Text("End Date:")
                }
                VStack(alignment: .leading) {
                    Text("\(trip.startDate, formatter: DateFormatter.shortDate)")
                    Text("\(trip.endDate, formatter: DateFormatter.shortDate)")
                }
            }
            .padding(.bottom, 20)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Trip Details")
    }
}

struct AddTripView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: TripViewModel
    
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Destination")) {
                    TextField("Enter destination", text: $destination)
                }
                
                Section(header: Text("Dates")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Trip")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Add") {
                viewModel.addTrip(destination: destination, startDate: startDate, endDate: endDate)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

extension DateFormatter {
    static var shortDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}


#Preview {
    TripsView()
}
