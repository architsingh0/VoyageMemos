//
//  TripViewModel.swift
//  Class Project
//
//  Created by Archit Singh on 10/22/23.
//

import Foundation
import CoreData

class TripViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    
    private var managedObjectContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
        fetchTrips()
    }

    func fetchTrips() {
        let request: NSFetchRequest<Trip> = Trip.fetchRequest()

        do {
            trips = try managedObjectContext.fetch(request)
            
        } catch {
            print("Error fetching trips: \(error)")
        }
    }

    func addTrip(destination: String, startDate: Date, endDate: Date, memos: [Memo]) -> Trip {
        let newTrip = Trip(context: managedObjectContext)
        newTrip.destination = destination
        newTrip.startDate = startDate
        newTrip.endDate = endDate
        newTrip.addToMemos(NSSet(array: memos))
        trips.append(newTrip)
        saveContext()
        return newTrip
    }


    func fetchTripForStartDate(_ startDate: Date) -> Trip? {
        return trips.first { trip in
            trip.startDate == startDate
        }
    }

    func removeTrip(at offsets: IndexSet) {
        for index in offsets {
            let trip = trips[index]
            managedObjectContext.delete(trip)
        }
        trips.remove(atOffsets: offsets)
        saveContext()
    }

    private func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
