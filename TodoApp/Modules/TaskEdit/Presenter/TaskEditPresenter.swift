//
//  TaskEditPresenter.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import Foundation

final class TaskEditPresenter {
    
    // MARK: - Properties
    
    weak var view: TaskEditViewInput?
    var interactor: TaskEditInteractorInput!
    var router: TaskEditRouterProtocol!
    
    // MARK: - Private Properties
    
    private var task: TaskEntity?
    
    // MARK: - Initialization
    
    init(task: TaskEntity? = nil) {
        self.task = task
    }
}

// MARK: - TaskEditViewOutput

extension TaskEditPresenter: TaskEditViewOutput {
    
    func viewDidLoad() {
    }
    
    func didTapSave(title: String, description: String) {
    }
    
    func didTapCancel() {
    }
}

// MARK: - TaskEditInteractorOutput

extension TaskEditPresenter: TaskEditInteractorOutput {
    
    func didCreateTask(_ task: TaskEntity) {
    }
    
    func didFailToCreateTask(with error: Error) {
    }
    
    func didUpdateTask(_ task: TaskEntity) {
    }
    
    func didFailToUpdateTask(with error: Error) {
    }
}
