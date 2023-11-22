//
//  TripsMapView.swift
//  Class Project
//
//  Created by Archit Singh on 11/22/23.
//

import SwiftUI
import CoreLocation
import MapKit

struct TripsMapView: View {
    @EnvironmentObject var viewModel:TripViewModel
    @State private var landmarks = [Landmark]()
    @State private var selectedLandmark: Landmark?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
    )
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView{
            MapView(landmarks: $landmarks, selectedLandmark: $selectedLandmark, region: $region)
                .padding()
                .navigationBarItems(trailing: Button("Dismiss") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
        .onAppear(perform: loadLandmarks)
    }

    private func loadLandmarks() {
        for trip in viewModel.trips {
            getCoordinates(destination: trip.destination) { placemark in
                let landmark = Landmark(placemark: placemark)
                self.landmarks.append(landmark)
            }
        }
    }

    private func getCoordinates(destination: String?, completion: @escaping (MKPlacemark) -> Void) {
        guard let destination = destination else { return }

        CLGeocoder().geocodeAddressString(destination) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error)")
                return
            }

            if let placemark = placemarks?.first {
                let mkPlacemark = MKPlacemark(placemark: placemark)
                completion(mkPlacemark)
            }
        }
    }
}



#Preview {
    TripsMapView()
}
