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
    }
    
    func openEditTask(_ task: TaskEntity) {
    }
}
