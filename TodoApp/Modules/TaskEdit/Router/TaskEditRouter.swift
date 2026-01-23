//
//  TaskEditRouter.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import UIKit

final class TaskEditRouter {
    
    // MARK: - Properties
    
    weak var viewController: UIViewController?
}

// MARK: - TaskEditRouterProtocol

extension TaskEditRouter: TaskEditRouterProtocol {
    
    func close() {
    }
}
