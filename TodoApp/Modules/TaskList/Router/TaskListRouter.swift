//
//  TaskListRouter.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import UIKit

final class TaskListRouter {
    
    // MARK: - Properties
    
    weak var viewController: UIViewController?
}

// MARK: - TaskListRouterProtocol

extension TaskListRouter: TaskListRouterProtocol {
    
    func openCreateTask() {
        let taskEditViewController = TaskEditAssembly().createModuleForNewTask()
        let navigationController = UINavigationController(rootViewController: taskEditViewController)
        navigationController.modalPresentationStyle = .pageSheet
        viewController?.present(navigationController, animated: true)
    }
    
    func openEditTask(_ task: TaskEntity) {
        let taskEditViewController = TaskEditAssembly().createModule(for: task)
        let navigationController = UINavigationController(rootViewController: taskEditViewController)
        navigationController.modalPresentationStyle = .fullScreen
        viewController?.present(navigationController, animated: true)
    }
}
