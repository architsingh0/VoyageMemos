//
//  MapView.swift
//  Class Project
//
//  Created by Archit Singh on 10/22/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

struct MapView: View {
    private static let defaultLocation = CLLocationCoordinate2D(
        latitude: 33.4255,
        longitude: -111.9400
    )
    @State private var region = MKCoordinateRegion(
        center: defaultLocation,
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    @State private var markers = [
        Location(name: "Tempe", coordinate: defaultLocation)
    ]
    var body: some View {
        VStack{
            Map(coordinateRegion: $region, interactionModes: .all, annotationItems: markers){ location in MapAnnotation(coordinate: location.coordinate){
                VStack{
                    Text(location.name)
                        .foregroundColor(.white)
                        .background(.red)
                        .cornerRadius(5.0)
                        .padding(5.0)
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                }
            }
            }
        }
    }
}

#Preview {
    MapView()
}
