//
//  TaskListViewModelTests.swift
//  TodoAppTests
//
//  Created by Тадевос Курдоглян on 13.04.2026.
//

import Testing
import Foundation
@testable import TodoApp

// @Suite группирует тесты — аналог XCTestCase класса
// @MainActor — потому что ViewModel и Repository помечены @MainActor
@Suite("TaskListViewModel Tests")
@MainActor
struct TaskListViewModelTests {

    // MARK: - loadTasks

    @Test("Успешная загрузка — tasks заполняются, isLoading сбрасывается")
    func loadTasks_success_populatesTasks() async {
        // Arrange — собираем систему
        let repo = MockTaskRepository()
        repo.stubbedTasks = TaskItem.mocks(count: 3)
        let sut = makeSUT(repository: repo)

        // Act
        await sut.loadTasks()

        // Assert
        #expect(sut.tasks.count == 3)
        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
    }

    @Test("Ошибка загрузки — errorMessage устанавливается")
    func loadTasks_failure_setsErrorMessage() async {
        let repo = MockTaskRepository()
        repo.shouldThrowError = true
        let sut = makeSUT(repository: repo)

        await sut.loadTasks()

        #expect(sut.tasks.isEmpty)
        #expect(sut.errorMessage != nil)
        #expect(sut.isLoading == false)
    }

    // MARK: - toggleCompletion

    @Test("Toggle — меняет isCompleted и вызывает update")
    func toggleCompletion_updatesItem() async {
        let repo = MockTaskRepository()
        let item = TaskItem.mock(isCompleted: false)
        repo.stubbedTasks = [item]
        let sut = makeSUT(repository: repo)
        await sut.loadTasks()

        await sut.toggleCompletion(item)

        // @Model объект мутируется напрямую
        #expect(item.isCompleted == true)
        #expect(repo.updateCalled == true)
    }

    @Test("Toggle — rollback при ошибке сохранения")
    func toggleCompletion_rollbackOnError() async {
        let repo = MockTaskRepository()
        let item = TaskItem.mock(isCompleted: false)
        repo.stubbedTasks = [item]
        let sut = makeSUT(repository: repo)
        await sut.loadTasks()

        // Включаем ошибку ПОСЛЕ loadTasks
        repo.shouldThrowError = true
        await sut.toggleCompletion(item)

        // Состояние должно откатиться
        #expect(item.isCompleted == false)
        #expect(sut.errorMessage != nil)
    }

    // MARK: - delete

    @Test("Удаление — убирает задачу из tasks")
    func delete_removesItemFromTasks() async {
        let repo = MockTaskRepository()
        repo.stubbedTasks = TaskItem.mocks(count: 3)
        let sut = makeSUT(repository: repo)
        await sut.loadTasks()

        let itemToDelete = sut.tasks[0]
        await sut.delete(itemToDelete)

        #expect(sut.tasks.count == 2)
        #expect(repo.deleteCalled == true)
        #expect(repo.lastDeletedId == itemToDelete.id)
    }

    // MARK: - createTask

    @Test("Создание задачи — добавляется в начало списка")
    func createTask_insertsAtBeginning() async {
        let repo = MockTaskRepository()
        let sut = makeSUT(repository: repo)

        await sut.createTask(title: "Новая задача", description: nil)

        #expect(sut.tasks.count == 1)
        #expect(sut.tasks[0].title == "Новая задача")
        #expect(repo.createCalled == true)
    }

    @Test("Создание с пустым title — выставляет errorMessage")
    func createTask_emptyTitle_setsError() async {
        let repo = MockTaskRepository()
        let sut = makeSUT(repository: repo)

        await sut.createTask(title: "  ", description: nil)

        #expect(sut.tasks.isEmpty)
        #expect(repo.createCalled == false)
        #expect(sut.errorMessage != nil)
    }

    @Test("Поиск — вызывает search на repository с правильным query")
    func loadTasks_withSearchQuery_callsSearch() async {
        let repo = MockTaskRepository()
        repo.stubbedTasks = [TaskItem.mock(title: "Купить молоко")]
        let sut = makeSUT(repository: repo)
        sut.searchQuery = "молоко"

        await sut.loadTasks()

        #expect(repo.searchCalled == true)
        #expect(repo.lastSearchQuery == "молоко")
        #expect(repo.fetchAllCalled == false)
    }

    // MARK: - Factory

    private func makeSUT(repository: MockTaskRepository) -> TaskListViewModel {
        TaskListViewModel(
            repository: repository,
            networkService: NetworkService()
        )
    }
}
