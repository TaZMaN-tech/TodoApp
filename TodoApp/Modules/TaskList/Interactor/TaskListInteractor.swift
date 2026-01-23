//
//  TaskListInteractor.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import Foundation


final class TaskListInteractor {
    
    // MARK: - Properties
    
    weak var presenter: TaskListInteractorOutput?
    private let repository: TaskRepositoryProtocol
    private let networkService: NetworkService
    private let userDefaults: UserDefaults
    private let firstLaunchKey = "TaskList.isFirstLaunch"
    
    // MARK: - Initialization
    
    init(
        repository: TaskRepositoryProtocol,
        networkService: NetworkService,
        userDefaults: UserDefaults = .standard
    ) {
        self.repository = repository
        self.networkService = networkService
        self.userDefaults = userDefaults
    }
}

// MARK: - TaskListInteractorInput

extension TaskListInteractor: TaskListInteractorInput {
    
    func loadTasks() {
        repository.fetchAll { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let tasks):
                self.presenter?.didLoadTasks(tasks)
                
            case .failure(let error):
                self.presenter?.didFailToLoadTasks(with: error)
            }
        }
    }
    
    func searchTasks(query: String) {
        repository.search(query: query) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let tasks):
                self.presenter?.didLoadTasks(tasks)
                
            case .failure(let error):
                self.presenter?.didFailToLoadTasks(with: error)
            }
        }
    }
    
    func deleteTask(taskId: Int64) {
        repository.delete(taskId: taskId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.presenter?.didDeleteTask(taskId: taskId)
                
            case .failure(let error):
                self.presenter?.didFailToDeleteTask(with: error)
            }
        }
    }
    
    func updateTaskCompletion(taskId: Int64, isCompleted: Bool) {
        repository.fetchAll { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let tasks):
                guard let task = tasks.first(where: { $0.id == taskId }) else {
                    let error = NSError(
                        domain: "TaskListInteractor",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "Задача не найдена"]
                    )
                    self.presenter?.didFailToUpdateTask(with: error)
                    return
                }
                
                let updatedTask = TaskEntity(
                    id: task.id,
                    title: task.title,
                    taskDescription: task.taskDescription,
                    createdDate: task.createdDate,
                    isCompleted: isCompleted
                )
                
                self.repository.update(task: updatedTask) { [weak self] updateResult in
                    guard let self = self else { return }
                    
                    switch updateResult {
                    case .success(let savedTask):
                        self.presenter?.didUpdateTask(savedTask)
                        
                    case .failure(let error):
                        self.presenter?.didFailToUpdateTask(with: error)
                    }
                }
                
            case .failure(let error):
                self.presenter?.didFailToUpdateTask(with: error)
            }
        }
    }
    
    func loadInitialDataIfNeeded() {
        let isFirstLaunch = !userDefaults.bool(forKey: firstLaunchKey)
        
        if isFirstLaunch {
            print("🚀 Первый запуск приложения - загружаем данные с API")
            
            presenter?.didStartLoading()
            
            networkService.fetchTodos { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let tasks):
                    print("✅ Загружено \(tasks.count) задач с API")
                    
                    self.repository.createBatch(tasks: tasks) { [weak self] saveResult in
                        guard let self = self else { return }
                        
                        switch saveResult {
                        case .success(let savedTasks):
                            print("✅ Сохранено \(savedTasks.count) задач в базу данных")
                            
                            self.userDefaults.set(true, forKey: self.firstLaunchKey)
                            self.presenter?.didFinishLoading()
                            self.presenter?.didLoadTasks(savedTasks)
                            
                        case .failure(let error):
                            print("❌ Ошибка сохранения задач: \(error)")
                            self.presenter?.didFinishLoading()
                            self.presenter?.didFailToLoadTasks(with: error)
                        }
                    }
                    
                case .failure(let error):
                    print("❌ Ошибка загрузки с API: \(error)")
                    self.presenter?.didFinishLoading()
                    self.presenter?.didFailToLoadTasks(with: error)
                }
            }
        } else {
            print("📱 Не первый запуск - загружаем данные из локальной базы")
            loadTasks()
        }
    }
}
