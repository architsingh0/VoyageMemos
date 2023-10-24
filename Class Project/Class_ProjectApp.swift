//
//  Class_ProjectApp.swift
//  Class Project
//
//  Created by Archit Singh on 10/22/23.
//

import SwiftUI

@main
struct Class_ProjectApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
