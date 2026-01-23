//
//  TaskListInteractor.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import Foundation


final class TaskListInteractor {
    
    // MARK: - Properties
    
    weak var presenter: TaskListInteractorOutput?
    private let repository: TaskRepositoryProtocol
    private let networkService: NetworkService
    private let firstLaunchKey = "TaskList.isFirstLaunch"
    
    // MARK: - Initialization
    
    init(
        repository: TaskRepositoryProtocol,
        networkService: NetworkService
    ) {
        self.repository = repository
        self.networkService = networkService
    }
}

// MARK: - TaskListInteractorInput

extension TaskListInteractor: TaskListInteractorInput {
    
    func loadTasks() {
    }
    
    func searchTasks(query: String) {
    }
    
    func deleteTask(taskId: Int64) {
    }
    
    func updateTaskCompletion(taskId: Int64, isCompleted: Bool) {
    }
    
    func loadInitialDataIfNeeded() {
    }
}
