//
//  TaskListProtocols.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import Foundation

// MARK: - View Input (Presenter → View)

protocol TaskListViewInput: AnyObject {
    func displayTasks(_ viewModels: [TaskViewModel])
    func showLoading()
    func hideLoading()
    func showError(message: String)
    func showEmptyState(message: String)
}

// MARK: - View Output (View → Presenter)

protocol TaskListViewOutput: AnyObject {
    func viewDidLoad()
    func didSelectTask(at index: Int)
    func didRequestDeleteTask(at index: Int)
    func didRequestEditTask(at index: Int)
    func didToggleTaskCompletion(at index: Int, isCompleted: Bool)
    func didChangeSearchQuery(_ query: String)
    func didTapAddTask()
    func didPullToRefresh()
}

// MARK: - Interactor Input (Presenter → Interactor)

protocol TaskListInteractorInput: AnyObject {
    func loadTasks()
    func searchTasks(query: String)
    func deleteTask(taskId: Int64)
    func updateTaskCompletion(taskId: Int64, isCompleted: Bool)
    func loadInitialDataIfNeeded()
}

// MARK: - Interactor Output (Interactor → Presenter)

protocol TaskListInteractorOutput: AnyObject {
    func didLoadTasks(_ tasks: [TaskEntity])
    func didFailToLoadTasks(with error: Error)
    func didDeleteTask(taskId: Int64)
    func didFailToDeleteTask(with error: Error)
    func didUpdateTask(_ task: TaskEntity)
    func didFailToUpdateTask(with error: Error)
    func didStartLoading()
    func didFinishLoading()
}

// MARK: - Router Protocol (Presenter → Router)

protocol TaskListRouterProtocol: AnyObject {
    func openCreateTask()
    func openEditTask(_ task: TaskEntity)
    func openTaskDetails(_ task: TaskEntity)
}

// MARK: - View Model

nonisolated struct TaskViewModel: Hashable {
    let id: Int64
    let title: String
    let description: String?
    let createdDateString: String
    let isCompleted: Bool
    let entity: TaskEntity
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TaskViewModel, rhs: TaskViewModel) -> Bool {
        return lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.createdDateString == rhs.createdDateString &&
        lhs.isCompleted == rhs.isCompleted
    }
}

// MARK: - Module Assembly Protocol

protocol TaskListModuleAssemblyProtocol {
    func createModule() -> TaskListViewController
}
