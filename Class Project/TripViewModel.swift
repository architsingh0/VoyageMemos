//
//  TripViewModel.swift
//  Class Project
//
//  Created by Archit Singh on 10/22/23.
//

import Foundation

class TripViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    
    func addTrip(destination: String, startDate: Date, endDate: Date) {
        let trip = Trip(destination: destination, startDate: startDate, endDate: endDate)
        trips.append(trip)
    }
    
    func removeTrip(at offsets: IndexSet) {
        trips.remove(atOffsets: offsets)
    }
}
