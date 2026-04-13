//
//  AppDependencies.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 13.04.2026.
//

import SwiftData

// @Observable — чтобы передавать через @Environment и SwiftUI мог отслеживать изменения
// Это единственное место где создаются все зависимости
@MainActor
@Observable
final class AppDependencies {

    // MARK: - Private services (детали реализации — скрыты)

    private let modelContext: ModelContext
    private let networkService: NetworkService

    // MARK: - Init

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.networkService = NetworkService()
    }

    // MARK: - Factories

    // Фабричный метод — каждый вызов создаёт новый ViewModel
    // Это правильно: ViewModel привязан к конкретному экрану
    func makeTaskListViewModel() -> TaskListViewModel {
        TaskListViewModel(
            repository: makeTaskRepository(),
            networkService: networkService
        )
    }

    // Repository — создаётся с тем же modelContext
    // Приватный — никто снаружи не должен создавать Repository напрямую
    private func makeTaskRepository() -> TaskRepositoryProtocol {
        TaskRepository(modelContext: modelContext)
    }
}
