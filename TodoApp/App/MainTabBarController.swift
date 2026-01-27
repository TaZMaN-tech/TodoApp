//
//  MainTabBarController.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 27.01.2026.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    // MARK: - Properties
    
    private let tasksCountLabel = UILabel()
    private let addButton = UIButton(type: .custom)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupViewControllers()
        setupCustomTabBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTasksCount()
    }
    
    // MARK: - Setup
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        if #available(iOS 13.0, *) {
            appearance.backgroundColor = .secondarySystemBackground
        } else {
            appearance.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        }
        
        appearance.stackedLayoutAppearance.normal.iconColor = .clear
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.stackedLayoutAppearance.selected.iconColor = .clear
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupViewControllers() {
        let taskListVC = TaskListAssembly().createModule()
        let navigationController = UINavigationController(rootViewController: taskListVC)
        navigationController.navigationBar.prefersLargeTitles = true
        
        navigationController.tabBarItem = UITabBarItem(title: "", image: nil, tag: 0)
        
        viewControllers = [navigationController]
    }
    
    // MARK: - Custom Tab Bar
    
    private func setupCustomTabBar() {
        tasksCountLabel.text = "0 Задач"
        tasksCountLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        tasksCountLabel.textAlignment = .center
        tasksCountLabel.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(tasksCountLabel)
        
        addButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        addButton.tintColor = .systemYellow
        addButton.backgroundColor = .clear // убедись что прозрачный фон
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: config)
        addButton.setImage(image, for: .normal)
        
        tabBar.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            tasksCountLabel.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            tasksCountLabel.centerYAnchor.constraint(equalTo: tabBar.centerYAnchor),
            
            addButton.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor, constant: -12),
            addButton.centerYAnchor.constraint(equalTo: tabBar.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 48),  // Большая hit area
            addButton.heightAnchor.constraint(equalToConstant: 48)  // Большая hit area
        ])
    }
    
    // MARK: - Public Methods
    
    func updateTasksCount() {
        guard let navigationController = viewControllers?.first as? UINavigationController,
              let taskListVC = navigationController.viewControllers.first as? TaskListViewController else {
            return
        }
        
        taskListVC.onTasksCountChanged = { [weak self] count in
            DispatchQueue.main.async {
                self?.tasksCountLabel.text = "\(count) Задач"
            }
        }
    }
    
    @objc private func addButtonTapped() {
        print("Add button tapped")
        
        guard let navigationController = viewControllers?.first as? UINavigationController else {
            print("No navigation controller")
            return
        }
        
        guard let taskListVC = navigationController.viewControllers.first as? TaskListViewController else {
            print("No TaskListViewController")
            return
        }
       
        print("Calling didTapAddTask")
        taskListVC.presenter.didTapAddTask()
    }
}
