//
//  TaskListViewController.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import UIKit

final class TaskListViewController: UIViewController {
    
    // MARK: - Properties
    
    var presenter: TaskListViewOutput!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Задачи"
        view.backgroundColor = .systemBackground
        
    }
}

// MARK: - TaskListViewInput

extension TaskListViewController: TaskListViewInput {
    
    func displayTasks(_ viewModels: [TaskViewModel]) {
    }
    
    func showLoading() {
    }
    
    func hideLoading() {
    }
    
    func showError(message: String) {
    }
    
    func showEmptyState(message: String) {
    }
}
