//
//  TaskListAssembly.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import UIKit

final class TaskListAssembly {
    
    // MARK: - Public Methods
    
    func createModule() -> TaskListViewController {
        let viewController = TaskListViewController()
        let repository = TaskRepository.shared
        let networkService = NetworkService()
        
        let interactor = TaskListInteractor(
            repository: repository,
            networkService: networkService
        )
        
        let router = TaskListRouter()
        let presenter = TaskListPresenter()
        
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.interactor = interactor
        interactor.presenter = presenter
        presenter.router = router
        router.viewController = viewController
        
        return viewController
    }
}

// MARK: - TaskListModuleAssemblyProtocol

extension TaskListAssembly: TaskListModuleAssemblyProtocol {
}

// MARK: - Convenience

extension TaskListAssembly {
    
    static func createModuleWithNavigation() -> UINavigationController {
        let assembly = TaskListAssembly()
        let viewController = assembly.createModule()
        let navigationController = UINavigationController(rootViewController: viewController)
        
        navigationController.navigationBar.prefersLargeTitles = true
        
        return navigationController
    }
}
