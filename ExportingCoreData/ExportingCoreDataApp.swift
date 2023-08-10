//
//  ExportingCoreDataApp.swift
//  ExportingCoreData
//
//  Created by Juan Carlos Catagña Tipantuña on 5/8/23.
//

import SwiftUI

@main
struct ExportingCoreDataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
