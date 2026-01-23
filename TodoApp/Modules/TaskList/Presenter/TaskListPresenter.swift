//
//  TaskListPresenter.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import Foundation

final class TaskListPresenter {
    
    // MARK: - Properties
    
    weak var view: TaskListViewInput?
    var interactor: TaskListInteractorInput!
    var router: TaskListRouterProtocol!
    
    // MARK: - Private Properties
    
    private var viewModels: [TaskViewModel] = []
    private var currentSearchQuery: String = ""
}

// MARK: - TaskListViewOutput

extension TaskListPresenter: TaskListViewOutput {
    
    func viewDidLoad() {
    }
    
    func didSelectTask(at index: Int) {
    }
    
    func didRequestDeleteTask(at index: Int) {
    }
    
    func didToggleTaskCompletion(at index: Int, isCompleted: Bool) {
    }
    
    func didChangeSearchQuery(_ query: String) {
    }
    
    func didTapAddTask() {
    }
    
    func didPullToRefresh() {
    }
}

// MARK: - TaskListInteractorOutput

extension TaskListPresenter: TaskListInteractorOutput {
    
    func didLoadTasks(_ tasks: [TaskEntity]) {
    }
    
    func didFailToLoadTasks(with error: Error) {
    }
    
    func didDeleteTask(taskId: Int64) {
    }
    
    func didFailToDeleteTask(with error: Error) {
    }
    
    func didUpdateTask(_ task: TaskEntity) {
    }
    
    func didFailToUpdateTask(with error: Error) {
    }
    
    func didStartLoading() {
    }
    
    func didFinishLoading() {
    }
}
