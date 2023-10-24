//
//  ExploreView.swift
//  Class Project
//
//  Created by Archit Singh on 10/22/23.
//

import SwiftUI

struct ExploreView: View {
    var body: some View {
        NavigationView {
            MapView()
                .navigationTitle("Explore Nearby")
        }
    }
}

#Preview {
    ExploreView()
}
