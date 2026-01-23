//
//  TaskEditInteractor.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import Foundation

final class TaskEditInteractor {
    
    // MARK: - Properties
    
    weak var presenter: TaskEditInteractorOutput?
    private let repository: TaskRepositoryProtocol
    
    // MARK: - Initialization

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }
}

// MARK: - TaskEditInteractorInput

extension TaskEditInteractor: TaskEditInteractorInput {
    
    func createTask(title: String, description: String?) {
    }
    
    func updateTask(_ task: TaskEntity) {
    }
}
