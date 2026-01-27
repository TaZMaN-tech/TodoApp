//
//  TaskEditPresenter.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import Foundation

final class TaskEditPresenter {
    
    // MARK: - Properties
    
    weak var view: TaskEditViewInput?
    var interactor: TaskEditInteractorInput!
    var router: TaskEditRouterProtocol!
    
    // MARK: - Private Properties
    
    private var task: TaskEntity?
    private let mode: TaskEditViewController.Mode
    
    
    // MARK: - Initialization
    
    init(task: TaskEntity?, mode: TaskEditViewController.Mode) {
        self.task = task
        self.mode = mode
        
        if mode == .view {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleTaskDidUpdate(_:)),
                name: .taskDidUpdate,
                object: nil
            )
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private methods
    
    @objc private func handleTaskDidUpdate(_ notification: Notification) {
        guard mode == .view,
              let updated = notification.object as? TaskEntity,
              updated.id == task?.id
        else { return }

        task = updated
        view?.displayTask(title: updated.title, description: updated.taskDescription)
    }
}


// MARK: - TaskEditViewOutput

extension TaskEditPresenter: TaskEditViewOutput {
    
    func didTapEdit() {
        guard mode == .view, let task else { return }
        router.openEdit(task: task)
    }
    
    
    func viewDidLoad() {
        if let task = task {
            view?.displayTask(title: task.title, description: task.taskDescription)
        }
    }
    
    func didTapSave(title: String, description: String) {
        guard mode != .view else { return }
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {
            view?.showError(message: "Название задачи не может быть пустым")
            return
        }
        
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalDescription = trimmedDescription.isEmpty ? nil : trimmedDescription
        
        view?.showLoading()
        
        switch mode {
        case .view:
            view?.hideLoading()
            return

        case .create:
            interactor.createTask(title: trimmedTitle, description: finalDescription)

        case .edit:
            guard let existingTask = task else {
                view?.hideLoading()
                view?.showError(message: "Ошибка: задача не найдена")
                return
            }

            let updatedTask = TaskEntity(
                id: existingTask.id,
                title: trimmedTitle,
                taskDescription: finalDescription,
                createdDate: existingTask.createdDate,
                isCompleted: existingTask.isCompleted
            )

            interactor.updateTask(updatedTask)
        }
    }
    
    func didTapCancel() {
        router.close()
    }
}

// MARK: - TaskEditInteractorOutput

extension TaskEditPresenter: TaskEditInteractorOutput {
    
    func didCreateTask(_ task: TaskEntity) {
        ThreadSafetyHelpers.ensureMainThread { [weak self] in
            guard let self = self else { return }
            self.view?.hideLoading()
            
            NotificationCenter.default.post(name: .taskListDidChange, object: nil)
            
            self.router.close()
        }
    }
    
    func didFailToCreateTask(with error: Error) {
        ThreadSafetyHelpers.ensureMainThread { [weak self] in
            guard let self = self else { return }
            self.view?.hideLoading()
            let message = "Не удалось создать задачу: \(error.localizedDescription)"
            self.view?.showError(message: message)
        }
    }
    
    func didUpdateTask(_ task: TaskEntity) {
        ThreadSafetyHelpers.ensureMainThread { [weak self] in
            guard let self = self else { return }
            self.view?.hideLoading()
            
            NotificationCenter.default.post(name: .taskListDidChange, object: nil)
            NotificationCenter.default.post(name: .taskDidUpdate, object: task)
            
            self.router.close()
        }
    }
    
    func didFailToUpdateTask(with error: Error) {
        ThreadSafetyHelpers.ensureMainThread { [weak self] in
            guard let self = self else { return }
            self.view?.hideLoading()
            let message = "Не удалось обновить задачу: \(error.localizedDescription)"
            self.view?.showError(message: message)
        }
    }
}
