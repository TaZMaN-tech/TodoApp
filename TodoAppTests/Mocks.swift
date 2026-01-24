//
//  Mocks.swift
//  TodoAppTests
//
//  Created by Тадевос Курдоглян on 24.01.2026.
//

import Foundation
@testable import TodoApp

// MARK: - Mock TaskRepositoryProtocol

final class MockTaskRepository: TaskRepositoryProtocol {
    
    // MARK: - Properties
    
    var tasksToReturn: [TaskEntity] = []
    var errorToReturn: Error?
    
    var fetchAllCalled = false
    
    var searchCalled = false
    var lastSearchQuery: String?
    
    var createCalled = false
    var lastCreatedTask: TaskEntity?
    
    var updateCalled = false
    var lastUpdatedTask: TaskEntity?
    
    var deleteCalled = false
    var lastDeletedTaskId: Int64?
    
    var createBatchCalled = false
    var lastBatchTasks: [TaskEntity]?
    
    // MARK: - TaskRepositoryProtocol
    
    func fetchAll(completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        fetchAllCalled = true
        
        if let error = errorToReturn {
            completion(.failure(error))
        } else {
            completion(.success(tasksToReturn))
        }
    }
    
    func search(query: String, completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        searchCalled = true
        lastSearchQuery = query
        
        if let error = errorToReturn {
            completion(.failure(error))
        } else {
            let filtered = tasksToReturn.filter {
                $0.title.lowercased().contains(query.lowercased()) ||
                ($0.taskDescription?.lowercased().contains(query.lowercased()) ?? false)
            }
            completion(.success(filtered))
        }
    }
    
    func create(task: TaskEntity, completion: @escaping (Result<TaskEntity, Error>) -> Void) {
        createCalled = true
        lastCreatedTask = task
        
        if let error = errorToReturn {
            completion(.failure(error))
        } else {
            tasksToReturn.append(task)
            completion(.success(task))
        }
    }
    
    func update(task: TaskEntity, completion: @escaping (Result<TaskEntity, Error>) -> Void) {
        updateCalled = true
        lastUpdatedTask = task
        
        if let error = errorToReturn {
            completion(.failure(error))
        } else {
            if let index = tasksToReturn.firstIndex(where: { $0.id == task.id }) {
                tasksToReturn[index] = task
            }
            completion(.success(task))
        }
    }
    
    func delete(taskId: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
        deleteCalled = true
        lastDeletedTaskId = taskId
        
        if let error = errorToReturn {
            completion(.failure(error))
        } else {
            tasksToReturn.removeAll { $0.id == taskId }
            completion(.success(()))
        }
    }
    
    func createBatch(tasks: [TaskEntity], completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        createBatchCalled = true
        lastBatchTasks = tasks
        
        if let error = errorToReturn {
            completion(.failure(error))
        } else {
            tasksToReturn.append(contentsOf: tasks)
            completion(.success(tasks))
        }
    }
}

// MARK: - Mock TaskListViewInput

final class MockTaskListView: TaskListViewInput {
    
    var displayTasksCalled = false
    var lastDisplayedViewModels: [TaskViewModel]?
    
    var showLoadingCalled = false
    var hideLoadingCalled = false
    
    var showErrorCalled = false
    var lastErrorMessage: String?
    
    var showEmptyStateCalled = false
    var lastEmptyStateMessage: String?
    
    func displayTasks(_ viewModels: [TaskViewModel]) {
        displayTasksCalled = true
        lastDisplayedViewModels = viewModels
    }
    
    func showLoading() {
        showLoadingCalled = true
    }
    
    func hideLoading() {
        hideLoadingCalled = true
    }
    
    func showError(message: String) {
        showErrorCalled = true
        lastErrorMessage = message
    }
    
    func showEmptyState(message: String) {
        showEmptyStateCalled = true
        lastEmptyStateMessage = message
    }
}

// MARK: - Mock TaskListInteractorInput

final class MockTaskListInteractor: TaskListInteractorInput {
    
    var loadTasksCalled = false
    var searchTasksCalled = false
    var lastSearchQuery: String?
    
    var deleteTaskCalled = false
    var lastDeletedTaskId: Int64?
    
    var updateTaskCompletionCalled = false
    var lastUpdatedTaskId: Int64?
    var lastUpdatedIsCompleted: Bool?
    
    var loadInitialDataIfNeededCalled = false
    
    func loadTasks() {
        loadTasksCalled = true
    }
    
    func searchTasks(query: String) {
        searchTasksCalled = true
        lastSearchQuery = query
    }
    
    func deleteTask(taskId: Int64) {
        deleteTaskCalled = true
        lastDeletedTaskId = taskId
    }
    
    func updateTaskCompletion(taskId: Int64, isCompleted: Bool) {
        updateTaskCompletionCalled = true
        lastUpdatedTaskId = taskId
        lastUpdatedIsCompleted = isCompleted
    }
    
    func loadInitialDataIfNeeded() {
        loadInitialDataIfNeededCalled = true
    }
}

// MARK: - Mock TaskListRouterProtocol

final class MockTaskListRouter: TaskListRouterProtocol {
    
    var openCreateTaskCalled = false
    var openEditTaskCalled = false
    var lastEditedTask: TaskEntity?
    
    func openCreateTask() {
        openCreateTaskCalled = true
    }
    
    func openEditTask(_ task: TaskEntity) {
        openEditTaskCalled = true
        lastEditedTask = task
    }
}

// MARK: - Mock TaskEditViewInput

final class MockTaskEditView: TaskEditViewInput {
    
    var displayTaskCalled = false
    var lastDisplayedTitle: String?
    var lastDisplayedDescription: String?
    
    var showLoadingCalled = false
    var hideLoadingCalled = false
    
    var showErrorCalled = false
    var lastErrorMessage: String?
    
    var dismissCalled = false
    
    func displayTask(title: String, description: String?) {
        displayTaskCalled = true
        lastDisplayedTitle = title
        lastDisplayedDescription = description
    }
    
    func showLoading() {
        showLoadingCalled = true
    }
    
    func hideLoading() {
        hideLoadingCalled = true
    }
    
    func showError(message: String) {
        showErrorCalled = true
        lastErrorMessage = message
    }
    
    func dismiss() {
        dismissCalled = true
    }
}

// MARK: - Mock TaskEditInteractorInput

final class MockTaskEditInteractor: TaskEditInteractorInput {
    
    var createTaskCalled = false
    var lastCreatedTitle: String?
    var lastCreatedDescription: String?
    
    var updateTaskCalled = false
    var lastUpdatedTask: TaskEntity?
    
    func createTask(title: String, description: String?) {
        createTaskCalled = true
        lastCreatedTitle = title
        lastCreatedDescription = description
    }
    
    func updateTask(_ task: TaskEntity) {
        updateTaskCalled = true
        lastUpdatedTask = task
    }
}

// MARK: - Mock TaskEditRouterProtocol

final class MockTaskEditRouter: TaskEditRouterProtocol {
    
    var closeCalled = false
    
    func close() {
        closeCalled = true
    }
}

// MARK: - Test Error

struct TestError: Error {
    let message: String
}
