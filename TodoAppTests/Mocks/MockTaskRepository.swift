//
//  MockTaskRepository.swift
//  TodoAppTests
//
//  Created by Тадевос Курдоглян on 13.04.2026.
//

import Foundation
@testable import TodoApp

// Mock — подменяет реальный Repository в тестах
// Без базы данных, без сети — чистый контроль поведения
@MainActor
final class MockTaskRepository: TaskRepositoryProtocol {

    // Stubbed данные — что вернут методы
    var stubbedTasks: [TaskItem] = []
    var shouldThrowError = false
    var errorToThrow: Error = TestError.generic

    // Spy флаги — проверяем что методы вызывались
    var fetchAllCalled = false
    var searchCalled = false
    var lastSearchQuery: String?
    var createCalled = false
    var updateCalled = false
    var deleteCalled = false
    var lastDeletedId: Int64?

    func fetchAll() async throws -> [TaskItem] {
        fetchAllCalled = true
        if shouldThrowError { throw errorToThrow }
        return stubbedTasks
    }

    func search(query: String) async throws -> [TaskItem] {
        searchCalled = true
        lastSearchQuery = query
        if shouldThrowError { throw errorToThrow }
        return stubbedTasks.filter {
            $0.title.localizedStandardContains(query)
        }
    }

    func create(task: TaskItem) async throws -> TaskItem {
        createCalled = true
        if shouldThrowError { throw errorToThrow }
        stubbedTasks.append(task)
        return task
    }

    func update(task: TaskItem) async throws -> TaskItem {
        updateCalled = true
        if shouldThrowError { throw errorToThrow }
        return task
    }

    func delete(taskId: Int64) async throws {
        deleteCalled = true
        lastDeletedId = taskId
        if shouldThrowError { throw errorToThrow }
        stubbedTasks.removeAll { $0.id == taskId }
    }

    func createBatch(tasks: [TaskItem]) async throws -> [TaskItem] {
        if shouldThrowError { throw errorToThrow }
        stubbedTasks.append(contentsOf: tasks)
        return tasks
    }
}

// Типизированная тестовая ошибка вместо NSError
enum TestError: Error {
    case generic
    case network
    case database
}
