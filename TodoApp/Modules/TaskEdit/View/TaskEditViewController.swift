//
//  TaskEditViewController.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import UIKit

final class TaskEditViewController: UIViewController {
    
    // MARK: - Properties
    
    var presenter: TaskEditViewOutput!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Новая задача"
        view.backgroundColor = .systemBackground
    }
}

// MARK: - TaskEditViewInput

extension TaskEditViewController: TaskEditViewInput {
    
    func displayTask(title: String, description: String?) {
    }
    
    func showLoading() {
    }
    
    func hideLoading() {
    }
    
    func showError(message: String) {
    }
    
    func dismiss() {
    }
}
