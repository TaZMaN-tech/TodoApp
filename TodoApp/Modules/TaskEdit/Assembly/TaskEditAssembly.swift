//
//  TaskEditAssembly.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import UIKit

final class TaskEditAssembly {
    
    // MARK: - Private Methods
    
    private func createModule(task: TaskEntity?) -> TaskEditViewController {
        let viewController = TaskEditViewController()
        let repository = TaskRepository.shared
        let interactor = TaskEditInteractor(repository: repository)
        let router = TaskEditRouter()
        let presenter = TaskEditPresenter(task: task)
        
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.interactor = interactor
        interactor.presenter = presenter
        presenter.router = router
        router.viewController = viewController
        
        return viewController
    }
}

// MARK: - TaskEditModuleAssemblyProtocol

extension TaskEditAssembly: TaskEditModuleAssemblyProtocol {
    
    func createModuleForNewTask() -> TaskEditViewController {
        return createModule(task: nil)
    }
    
    func createModule(for task: TaskEntity) -> TaskEditViewController {
        return createModule(task: task)
    }
}
