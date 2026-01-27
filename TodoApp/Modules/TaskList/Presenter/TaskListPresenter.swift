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
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    // MARK: - Private Properties
    
    private var viewModels: [TaskViewModel] = []
    private var currentSearchQuery: String = ""
    
    // MARK: - Initialization
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(taskListDidChange),
            name: .taskListDidChange,
            object: nil
        )
    }
    
    // MARK: - Deinitialization
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notification Handlers
    
    @objc private func taskListDidChange() {
        if currentSearchQuery.isEmpty {
            interactor.loadTasks()
        } else {
            interactor.searchTasks(query: currentSearchQuery)
        }
    }
}

// MARK: - TaskListViewOutput

extension TaskListPresenter: TaskListViewOutput {
    
    func viewDidLoad() {
        view?.showLoading()
        interactor.loadInitialDataIfNeeded()
    }
    
    func didSelectTask(at index: Int) {
        guard index >= 0 && index < viewModels.count else {
            print("⚠️ Некорректный индекс задачи: \(index)")
            return
        }
        
        let viewModel = viewModels[index]
        let task = viewModel.entity
        
        router.openTaskDetails(task)
    }
    
    func didRequestEditTask(at index: Int) {
        guard index >= 0 && index < viewModels.count else {
            print("⚠️ Некорректный индекс задачи: \(index)")
            return
        }

        let task = viewModels[index].entity
        router.openEditTask(task)
    }
    
    func didRequestDeleteTask(at index: Int) {
        guard index >= 0 && index < viewModels.count else {
            print("⚠️ Некорректный индекс задачи: \(index)")
            return
        }
        
        let viewModel = viewModels[index]
        let taskId = viewModel.id
        
        interactor.deleteTask(taskId: taskId)
    }
    
    func didToggleTaskCompletion(at index: Int, isCompleted: Bool) {
        guard index >= 0 && index < viewModels.count else {
            print("⚠️ Некорректный индекс задачи: \(index)")
            return
        }
        
        let viewModel = viewModels[index]
        let taskId = viewModel.id
        
        var updatedViewModels = viewModels
        var updatedViewModel = viewModel
        
        let updatedEntity = TaskEntity(
            id: updatedViewModel.entity.id,
            title: updatedViewModel.entity.title,
            taskDescription: updatedViewModel.entity.taskDescription,
            createdDate: updatedViewModel.entity.createdDate,
            isCompleted: isCompleted
        )
        
        updatedViewModel = TaskViewModel(
            id: updatedEntity.id,
            title: updatedEntity.title,
            description: updatedEntity.taskDescription,
            createdDateString: dateFormatter.string(from: updatedEntity.createdDate),
            isCompleted: updatedEntity.isCompleted,
            entity: updatedEntity
        )
        
        updatedViewModels[index] = updatedViewModel
        viewModels = updatedViewModels
        
        view?.displayTasks(viewModels)
        
        interactor.updateTaskCompletion(taskId: taskId, isCompleted: isCompleted)
    }
    
    func didChangeSearchQuery(_ query: String) {
        currentSearchQuery = query
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        
        if trimmedQuery.isEmpty {
            interactor.loadTasks()
        } else {
            interactor.searchTasks(query: trimmedQuery)
        }
    }
    
    func didTapAddTask() {
        router.openCreateTask()
    }
    
    func didPullToRefresh() {
        if currentSearchQuery.isEmpty {
            interactor.loadTasks()
        } else {
            interactor.searchTasks(query: currentSearchQuery)
        }
    }
}

// MARK: - TaskListInteractorOutput

extension TaskListPresenter: TaskListInteractorOutput {
    
    func didLoadTasks(_ tasks: [TaskEntity]) {
        viewModels = tasks.map { entity in
            createViewModel(from: entity)
        }
        
        ThreadSafetyHelpers.ensureMainThread { [weak self] in
            guard let self = self else { return }
            
            self.view?.hideLoading()
            
            if self.viewModels.isEmpty {
                let message = self.currentSearchQuery.isEmpty
                ? "У вас пока нет задач.\nСоздайте первую!"
                : "Ничего не найдено по запросу \"\(self.currentSearchQuery)\""
                self.view?.showEmptyState(message: message)
            } else {
                self.view?.displayTasks(self.viewModels)
            }
        }
    }
    
    func didFailToLoadTasks(with error: Error) {
        let message = formatError(error)
        
        ThreadSafetyHelpers.ensureMainThread { [weak self] in
            guard let self = self else { return }
            self.view?.hideLoading()
            self.view?.showError(message: message)
        }
    }
    
    func didDeleteTask(taskId: Int64) {
        ThreadSafetyHelpers.ensureMainThread { [weak self] in
            guard let self = self else { return }
            
            self.viewModels.removeAll { $0.id == taskId }
            
            if self.viewModels.isEmpty {
                let message = self.currentSearchQuery.isEmpty
                ? "У вас пока нет задач.\nСоздайте первую!"
                : "Ничего не найдено по запросу \"\(self.currentSearchQuery)\""
                self.view?.showEmptyState(message: message)
            } else {
                self.view?.displayTasks(self.viewModels)
            }
            NotificationCenter.default.post(name: .taskListDidChange, object: nil)
        }
    }
    
    func didFailToDeleteTask(with error: Error) {
        let message = "Не удалось удалить задачу: \(formatError(error))"
        
        ThreadSafetyHelpers.ensureMainThread { [weak self] in
            guard let self = self else { return }
            self.view?.showError(message: message)
        }
    }
    
    func didUpdateTask(_ task: TaskEntity) {
        ThreadSafetyHelpers.ensureMainThread { [weak self] in
            guard let self = self else { return }
            
            if let index = self.viewModels.firstIndex(where: { $0.id == task.id }) {
                let updatedViewModel = self.createViewModel(from: task)
                self.viewModels[index] = updatedViewModel
                self.view?.displayTasks(self.viewModels)
            }
        }
    }
    
    func didFailToUpdateTask(with error: Error) {
        let message = "Не удалось обновить задачу: \(formatError(error))"
        
        ThreadSafetyHelpers.ensureMainThread { [weak self] in
            guard let self = self else { return }
            self.interactor.loadTasks()
            self.view?.showError(message: message)
        }
    }
    
    func didStartLoading() {
        ThreadSafetyHelpers.ensureMainThread { [weak self] in
            self?.view?.showLoading()
        }
    }
    
    func didFinishLoading() {
        ThreadSafetyHelpers.ensureMainThread { [weak self] in
            self?.view?.hideLoading()
        }
    }
}

// MARK: - Private Helpers

private extension TaskListPresenter {
    
    func createViewModel(from entity: TaskEntity) -> TaskViewModel {
        return TaskViewModel(
            id: entity.id,
            title: entity.title,
            description: entity.taskDescription,
            createdDateString: dateFormatter.string(from: entity.createdDate),
            isCompleted: entity.isCompleted,
            entity: entity
        )
    }
    
    func formatError(_ error: Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .networkError:
                return "Проверьте подключение к интернету"
            case .invalidResponse:
                return "Получен некорректный ответ от сервера"
            case .httpError(let statusCode):
                return "Ошибка сервера (код \(statusCode))"
            case .noData:
                return "Сервер не вернул данные"
            case .decodingError:
                return "Ошибка обработки данных"
            }
        }
        
        return error.localizedDescription
    }
}
