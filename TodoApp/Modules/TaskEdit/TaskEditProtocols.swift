//
//  TaskEditProtocols.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import Foundation

// MARK: - View Input (Presenter → View)

protocol TaskEditViewInput: AnyObject {
    func displayTask(title: String, description: String?)
    func showLoading()
    func hideLoading()
    func showError(message: String)
    func dismiss()
}

// MARK: - View Output (View → Presenter)

protocol TaskEditViewOutput: AnyObject {
    func viewDidLoad()
    func didTapSave(title: String, description: String)
    func didTapCancel()
}

// MARK: - Interactor Input (Presenter → Interactor)

protocol TaskEditInteractorInput: AnyObject {
    func createTask(title: String, description: String?)
    func updateTask(_ task: TaskEntity)
}

// MARK: - Interactor Output (Interactor → Presenter)

protocol TaskEditInteractorOutput: AnyObject {
    func didCreateTask(_ task: TaskEntity)
    func didFailToCreateTask(with error: Error)
    func didUpdateTask(_ task: TaskEntity)
    func didFailToUpdateTask(with error: Error)
}

// MARK: - Router Protocol (Presenter → Router)

protocol TaskEditRouterProtocol: AnyObject {
    func close()
}

// MARK: - Module Assembly Protocol

protocol TaskEditModuleAssemblyProtocol {
    func createModuleForNewTask() -> TaskEditViewController
    func createModule(for task: TaskEntity) -> TaskEditViewController
}
