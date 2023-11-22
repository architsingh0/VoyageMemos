//
//  TripsView.swift
//  Class Project
//
//  Created by Archit Singh on 10/22/23.
//

import SwiftUI

struct TripsView: View {
    @EnvironmentObject var viewModel:TripViewModel
    
    @State private var showingAddTrip = false
    @State private var showingMap = false
    
    var body: some View {
       NavigationView {
           List {
               ForEach(viewModel.trips, id: \.objectID) { trip in
                   NavigationLink(destination: TripDetailView(trip: trip)) {
                       VStack(alignment: .leading) {
                           Text(trip.destination ?? "Unknown Destination")
                               .font(.headline)
                           if let startDate = trip.startDate, let endDate = trip.endDate {
                               Text("\(startDate, formatter: DateFormatter.shortDate) - \(endDate, formatter: DateFormatter.shortDate)")
                                   .font(.subheadline)
                                   .foregroundColor(.gray)
                           } else {
                               Text("Unknown Dates")
                                   .font(.subheadline)
                                   .foregroundColor(.gray)
                           }
                       }
                   }
               }
               .onDelete(perform: viewModel.removeTrip)
           }
           .navigationTitle("My Trips")
           .navigationBarItems(
               leading: EditButton(),
               trailing: HStack{
                   Button(action: { showingMap = true}){
                       Image(systemName: "map")
                   }
                   Button(action: { showingAddTrip = true }) {
                      Image(systemName: "plus")
                   }
               }
           )
       }
       .sheet(isPresented: $showingAddTrip) {
           AddTripView()
       }
       .sheet(isPresented: $showingMap){
           TripsMapView()
       }
   }
}

struct TripDetailView: View {
    var trip: Trip
    
    var body: some View {
        VStack {
            Text(trip.destination!)
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Start Date:")
                    Text("End Date:")
                }
                VStack(alignment: .leading) {
                    Text("\(trip.startDate!, formatter: DateFormatter.shortDate)")
                    Text("\(trip.endDate!, formatter: DateFormatter.shortDate)")
                }
            }
            .padding(.bottom, 20)
            
            Spacer()
            
            MemoView(trip: trip)
                .background(.clear)
        }
        .padding()
        .navigationTitle("Trip Details")
    }
}

struct AddTripView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: TripViewModel
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var memos: [Memo] = []
    @State private var showingAddMemo = false
    @State private var newTrip: Trip?

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
                Section(header: Text("Memos")) {
                    ForEach(memos, id: \.self) { memo in
                        Text(memo.title ?? "No Title")
                    }
                    Button("Add Memo") {
                        let createdTrip = viewModel.addTrip(destination: destination, startDate: startDate, endDate: endDate, memos: memos)
                        self.newTrip = createdTrip
                        showingAddMemo = true
                    }
                    
                }
            }
            .navigationBarTitle("Add Trip")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Add") {
                if newTrip == nil {
                    let createdTrip = viewModel.addTrip(destination: destination, startDate: startDate, endDate: endDate, memos: memos)
                    self.newTrip = createdTrip
                }
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingAddMemo) {
                AddMemoView(trip: newTrip!, memos: $memos)
            }
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
