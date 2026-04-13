//
//  TaskListViewModel.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 13.04.2026.
//

import Foundation
import Observation   // ← фреймворк для @Observable

// @Observable заменяет: ObservableObject + все @Published
// Плюс: гранулярные обновления — SwiftUI перерисует только
// те части View, которые читают изменившееся свойство
@Observable
@MainActor
final class TaskListViewModel {

    // MARK: - State
    // Нет @Published — @Observable отслеживает всё автоматически
    var tasks: [TaskItem] = []
    var searchQuery: String = ""
    var isLoading = false
    var errorMessage: String?

    // MARK: - Dependencies
    // @ObservationIgnored — говорим макросу "не отслеживай это свойство"
    // Зависимости не должны триггерить перерисовку UI
    @ObservationIgnored
    private let repository: TaskRepositoryProtocol

    @ObservationIgnored
    private let networkService: NetworkService

    init(repository: TaskRepositoryProtocol, networkService: NetworkService) {
        self.repository = repository
        self.networkService = networkService
    }

    // MARK: - Intents (то что раньше было в Presenter)

    func loadTasks() async {
        isLoading = true
        errorMessage = nil
        do {
            // searchQuery пуст → fetchAll, иначе → search
            tasks = searchQuery.isEmpty
                ? try await repository.fetchAll()
                : try await repository.search(query: searchQuery)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadInitialDataIfNeeded() async {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "isFirstLaunch")
        if isFirstLaunch {
            await fetchFromAPI()
        } else {
            await loadTasks()
        }
    }

    func toggleCompletion(_ item: TaskItem) async {
        // Оптимистичное обновление: сначала меняем UI, потом сохраняем
        item.isCompleted.toggle()   // SwiftData @Model — просто меняем свойство
        do {
            try await repository.update(task: item)   // сохраняем
        } catch {
            item.isCompleted.toggle()  // rollback при ошибке
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ item: TaskItem) async {
        do {
            try await repository.delete(taskId: item.id)
            tasks.removeAll { $0.id == item.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createTask(title: String, description: String?) async {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            errorMessage = "Название не может быть пустым"
            return
        }
        let newItem = TaskItem(
            id: Int64(Date().timeIntervalSince1970 * 1000),
            title: trimmed,
            taskDescription: description
        )
        do {
            let saved = try await repository.create(task: newItem)
            tasks.insert(saved, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private

    private func fetchFromAPI() async {
        isLoading = true
        do {
            let items = try await networkService.fetchTodos()
            _ = try await repository.createBatch(tasks: items)
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
            await loadTasks()
        } catch {
            errorMessage = "Не удалось загрузить данные: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
