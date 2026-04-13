//
//  ContentView.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 13.04.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // @Environment(\.modelContext) — SwiftData внедряет контекст автоматически
    // из .modelContainer() который мы поставили в BookNookApp
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        // Собираем зависимости здесь — единственное место создания графа объектов
        let repository = TaskRepository(modelContext: modelContext)
        let networkService = NetworkService()
        let viewModel = TaskListViewModel(
            repository: repository,
            networkService: networkService
        )

        TaskListView(viewModel: viewModel)
    }
}
