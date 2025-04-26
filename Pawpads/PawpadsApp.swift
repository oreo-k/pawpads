//
//  PawpadsApp.swift
//  Pawpads
//
//  Created by REO KOSAKA on 4/25/25.
//

import SwiftUI

@main
struct PawpadsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
