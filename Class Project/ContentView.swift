//
//  ContentView.swift
//  Class Project
//
//  Created by Archit Singh on 10/22/23.
//

import SwiftUI

struct ContentView: View {
    @State private var hasSeenGetStarted = UserDefaults.standard.bool(forKey: "hasSeenGetStarted")

    var body: some View {
        if hasSeenGetStarted {
            MainView()
        } else {
            GetStartedView(hasSeenGetStarted: $hasSeenGetStarted)
        }
    }
}

struct GetStartedView: View {
    @Binding var hasSeenGetStarted: Bool

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Text("Welcome to VoyageMemos")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Preserve your travel memories effortlessly.")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                Spacer()
                
                NavigationLink("Get Started", destination: MainView().onAppear(perform: saveUserPreference))
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Capsule())
                .padding()
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                               startPoint: .top,
                               endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            )
            .navigationBarHidden(true)
        }
    }

    private func saveUserPreference() {
        UserDefaults.standard.set(true, forKey: "hasSeenGetStarted")
        hasSeenGetStarted = true
    }
}

struct MainView: View {
    var body: some View{
        TabView {
            TripsView()
                .tabItem {
                    Image(systemName: "airplane")
                    Text("Trips")
            }
            ExploreView()
                .tabItem {
                    Image(systemName: "safari")
                    Text("Explore")
            }
        }
        .accentColor(.cyan)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ContentView()
}
