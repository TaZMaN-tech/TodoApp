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
    
    func openEdit(task: TaskEntity) {
        let editVC = TaskEditAssembly().createModuleForEdit(task: task)
        viewController?.navigationController?.pushViewController(editVC, animated: true)
    }
    
    
    func close() {
        if viewController?.presentingViewController != nil {
            viewController?.dismiss(animated: true)
        } else {
            viewController?.navigationController?.popViewController(animated: true)
        }
    }
}
