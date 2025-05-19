//
//  MentalHealthAppApp.swift
//  MentalHealthApp
//
//  Created by Jeremy Tucker on 5/19/25.
//

import SwiftUI

@main
struct MentalHealthAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
