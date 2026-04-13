//
//  BookNookApp.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 13.04.2026.
//

import SwiftUI
import SwiftData

@main
struct BookNookApp: App {
    // ModelContainer — это аналог CoreDataStack, но декларативный.
    // Создаём один раз на весь App lifecycle.
    let container: ModelContainer = {
        let schema = Schema([TaskItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("SwiftData container failed: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
