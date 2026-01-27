//
//  TaskEditAssembly.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import UIKit

final class TaskEditAssembly {

    // MARK: - Private

    private func createModule(task: TaskEntity?, mode: TaskEditViewController.Mode) -> TaskEditViewController {
        let viewController = TaskEditViewController(mode: mode)

        let repository = TaskRepository.shared
        let interactor = TaskEditInteractor(repository: repository)
        let router = TaskEditRouter()
        let presenter = TaskEditPresenter(task: task, mode: mode) // ✅ меняем init

        viewController.presenter = presenter

        presenter.view = viewController
        presenter.interactor = interactor
        presenter.router = router

        interactor.presenter = presenter
        router.viewController = viewController

        return viewController
    }
}

// MARK: - TaskEditModuleAssemblyProtocol

extension TaskEditAssembly: TaskEditModuleAssemblyProtocol {

    func createModuleForNewTask() -> TaskEditViewController {
        createModule(task: nil, mode: .create)
    }

    func createModule(for task: TaskEntity) -> TaskEditViewController {
        createModule(task: task, mode: .edit)
    }


    func createModuleForView(task: TaskEntity) -> TaskEditViewController {
        createModule(task: task, mode: .view)
    }

    func createModuleForEdit(task: TaskEntity) -> TaskEditViewController {
        createModule(task: task, mode: .edit)
    }
}
