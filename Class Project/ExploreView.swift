//
//  ExploreView.swift
//  Class Project
//
//  Created by Archit Singh on 10/22/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct ExploreView: View {
    @Environment(\.scenePhase) var scenePhase
        @StateObject var locationManager = LocationManager()
        @State var landmarks: [Landmark] = []
        @State var selectedLandmark: Landmark?
        @State var searchText: String = ""
        @State var region = MKCoordinateRegion()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("See beautiful pictures for the landmarks around you")
                    .padding()
                HStack{
                    TextField("Search for landmarks", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button(action: {
                        performSearch()
                    }){
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                            .font(.title)
                    }
                    .padding()
                }
                

                MapView(landmarks: $landmarks, selectedLandmark: $selectedLandmark, region: $region)
                ListView(landmarks: $landmarks, selectedLandmark: $selectedLandmark)
            }
            .navigationTitle("Inspire your Travels")
        }
        .onAppear {
            locationManager.onLocationUpdate = { location in
                region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            }
        }
        .sheet(item: $selectedLandmark) { landmark in
            LandmarkDetailView(landmark: landmark)
        }
    }
    
    func performSearch(){
        fetchLandmarks(region: region)
    }

    func fetchLandmarks(region: MKCoordinateRegion) {
        if searchText.isEmpty {
            searchText = "Landmarks"
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region

        let search = MKLocalSearch(request: request)
        search.start { (response, _) in
            landmarks = response?.mapItems.map { Landmark(placemark: $0.placemark) } ?? []
        }
    }
}

struct MapView: View {
    @Binding var landmarks: [Landmark]
    @Binding var selectedLandmark: Landmark?
    @Binding var region: MKCoordinateRegion

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: landmarks) { landmark in
            MapAnnotation(coordinate: landmark.coordinate) {
                VStack {
                    Text(landmark.name).font(.caption)
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .onTapGesture {
                            selectedLandmark = landmark
                        }
                }
            }
        }
    }
}

struct ListView: View {
    @Binding var landmarks: [Landmark]
    @Binding var selectedLandmark: Landmark?

    var body: some View {
        List(landmarks, id: \.id) { landmark in
            Text(landmark.name)
                .onTapGesture {
                    selectedLandmark = landmark
                }
        }
    }
}

struct LandscapeModePromptView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack {
            Image(systemName: "iphone.landscape")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(isAnimating ? 20 : -20))
                .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
            Text("Please rotate your device to landscape mode.")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LandmarkDetailView: View {
    @State private var showLandscapePrompt = true
    @Environment(\.presentationMode) var presentationMode
    var landmark: Landmark
    @StateObject var viewModel = CityImageViewModel()
    @State private var isShowingFullScreenImageViewer = false
    @State private var selectedImage: UIImage?

    var body: some View {
        Group{
            if showLandscapePrompt == true{
                LandscapeModePromptView()
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                            showLandscapePrompt = false
                        }
                    }
            }
            else{
                NavigationView {
                    VStack {
                        Text(landmark.name)
                            .font(.title)
                        Text("Swipe to the left to see all images")
                        if viewModel.images.isEmpty {
                            ProgressView("Loading images...")
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.images, id: \.self) { image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .onTapGesture {
                                                self.selectedImage = image
                                                self.isShowingFullScreenImageViewer = true
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .navigationBarItems(trailing: Button("Dismiss") {
                        presentationMode.wrappedValue.dismiss()
                    })
                    .onAppear {
                        Task {
                            await viewModel.fetchImages(for: landmark.name)
                        }
                    }
                }            }
        }
    }
}

class CityImageViewModel: ObservableObject {
    @Published var images: [UIImage] = []

    func fetchImages(for landmarkName: String) async {
        let urlString = "https://api.unsplash.com/search/photos?query=\(landmarkName)&client_id=YOUR_API_KEY"
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(UnsplashResponse.self, from: data)
            
            await withTaskGroup(of: UIImage?.self) { group in
                for photo in response.results {
                    group.addTask {
                        await self.loadImage(from: URL(string: photo.urls.regular))
                    }
                }

                for await image in group {
                    if let img = image {
                        DispatchQueue.main.async {
                            self.images.append(img)
                        }
                    }
                }
            }
        } catch {
            
        }
    }

    private func loadImage(from url: URL?) async -> UIImage? {
        guard let url = url else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
}

struct UnsplashResponse: Codable {
    let results: [UnsplashPhoto]
}

struct UnsplashPhoto: Codable {
    let urls: UnsplashPhotoURLs
}

struct UnsplashPhotoURLs: Codable {
    let regular: String
}

struct Landmark: Identifiable {
    let placemark: MKPlacemark

    var id: UUID {
        return UUID()
    }

    var name: String {
        return placemark.name ?? ""
    }

    var coordinate: CLLocationCoordinate2D {
        return placemark.coordinate
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var onLocationUpdate: ((CLLocation) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            onLocationUpdate?(location)
        }
    }
}

#Preview {
    ExploreView()
}
