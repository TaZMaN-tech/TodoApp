//
//  MainTabBarController.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 27.01.2026.
//

import UIKit

/// Кастомный bottom bar с счётчиком задач и кнопкой добавления
final class BottomBarView: UIView {
    
    // MARK: - Properties
    
    /// Callback при нажатии на кнопку добавления
    var onAddButtonTapped: (() -> Void)?
    
    private let tasksCountLabel = UILabel()
    private let addButton = UIButton(type: .custom)
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Фон как у search bar
        backgroundColor = .secondarySystemBackground
        
        // Счётчик задач по центру
        tasksCountLabel.text = "0 Задач"
        tasksCountLabel.textColor = .systemYellow
        tasksCountLabel.font = .systemFont(ofSize: 17, weight: .regular)
        tasksCountLabel.textAlignment = .center
        tasksCountLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tasksCountLabel)
        
        // Кнопка добавления справа
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: config)
        addButton.setImage(image, for: .normal)
        addButton.tintColor = .yellow
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addSubview(addButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Счётчик по центру
            tasksCountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            tasksCountLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Кнопка справа с большой hit area
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 48),
            addButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    // MARK: - Public Methods
    
    /// Обновляет счётчик задач
    /// - Parameter count: Количество задач
    func updateTasksCount(_ count: Int) {
        tasksCountLabel.text = "\(count) Задач"
    }
    
    @objc private func addButtonTapped() {
        onAddButtonTapped?()
    }
}
