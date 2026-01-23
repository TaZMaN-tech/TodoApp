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
        let taskId = Int64(Date().timeIntervalSince1970 * 1000)
        
        let newTask = TaskEntity(
            id: taskId,
            title: title,
            taskDescription: description,
            createdDate: Date(),
            isCompleted: false
        )
        
        repository.create(task: newTask) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let savedTask):
                self.presenter?.didCreateTask(savedTask)
                
            case .failure(let error):
                self.presenter?.didFailToCreateTask(with: error)
            }
        }
    }
    
    func updateTask(_ task: TaskEntity) {
        repository.update(task: task) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let updatedTask):
                self.presenter?.didUpdateTask(updatedTask)
                
            case .failure(let error):
                self.presenter?.didFailToUpdateTask(with: error)
            }
        }
    }
}
