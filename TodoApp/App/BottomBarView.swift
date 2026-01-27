//
//  BottomBarView.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 27.01.2026.
//

import UIKit

final class BottomBarView: UIView {

    // MARK: - Properties

    var onAddButtonTapped: (() -> Void)?

    private let tasksCountLabel = UILabel()
    private let addButton = UIButton(type: .custom)

    private var labelCenterYConstraint: NSLayoutConstraint!
    private var buttonCenterYConstraint: NSLayoutConstraint!

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
        backgroundColor = .secondarySystemBackground

        tasksCountLabel.text = "0 задач"
        tasksCountLabel.font = .systemFont(ofSize: 15, weight: .regular)
        tasksCountLabel.textAlignment = .center
        tasksCountLabel.textColor = .label
        tasksCountLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tasksCountLabel)

        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: config)
        addButton.setImage(image, for: .normal)
        addButton.tintColor = .systemYellow
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addSubview(addButton)

        let lift: CGFloat = -6

        labelCenterYConstraint = tasksCountLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: lift)
        buttonCenterYConstraint = addButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: lift)

        NSLayoutConstraint.activate([
            tasksCountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            labelCenterYConstraint,

            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonCenterYConstraint,
            addButton.widthAnchor.constraint(equalToConstant: 48),
            addButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    // MARK: - Public Methods

    func updateTasksCount(_ count: Int) {
        tasksCountLabel.text = "\(count) \(Self.pluralize(count, one: "задача", few: "задачи", many: "задач"))"
    }

    func setLift(_ lift: CGFloat) {
        labelCenterYConstraint.constant = lift
        buttonCenterYConstraint.constant = lift
        layoutIfNeeded()
    }

    @objc private func addButtonTapped() {
        onAddButtonTapped?()
    }

    // MARK: - Russian pluralization

    private static func pluralize(_ number: Int, one: String, few: String, many: String) -> String {
        let n = abs(number)
        let mod100 = n % 100
        if (11...14).contains(mod100) { return many }

        switch n % 10 {
        case 1: return one
        case 2, 3, 4: return few
        default: return many
        }
    }
}
