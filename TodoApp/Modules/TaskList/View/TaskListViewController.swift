//
//  TaskListViewController.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import UIKit

final class TaskListViewController: UIViewController {

    // MARK: - Section Definition

    nonisolated private enum Section: Hashable {
        case main
    }

    // MARK: - Properties

    var presenter: TaskListViewOutput!

    // MARK: - UI

    private let searchContainer = UIView()
    private let bottomBar = BottomBarView()

    private var bottomBarHeightConstraint: NSLayoutConstraint!

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseIdentifier)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        table.separatorStyle = .singleLine
        table.backgroundColor = .systemBackground
        table.backgroundView = {
            let v = UIView()
            v.backgroundColor = .systemBackground
            return v
        }()
        table.contentInsetAdjustmentBehavior = .automatic
        return table
    }()

    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.placeholder = "Поиск задач"
        bar.searchBarStyle = .minimal
        bar.autocapitalizationType = .none
        bar.autocorrectionType = .no
        bar.delegate = self
        return bar
    }()

    /// Diffable Data Source для таблицы
    private lazy var dataSource: UITableViewDiffableDataSource<Section, TaskViewModel> = {
        let ds = UITableViewDiffableDataSource<Section, TaskViewModel>(
            tableView: tableView
        ) { [weak self] tableView, indexPath, viewModel in
            guard let self = self else { return UITableViewCell() }

            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: TaskCell.reuseIdentifier,
                for: indexPath
            ) as? TaskCell else {
                return UITableViewCell()
            }

            cell.configure(with: viewModel)

            cell.onToggleCompletion = { [weak self] in
                guard let self else { return }
                let snapshot = self.dataSource.snapshot()
                if let index = snapshot.indexOfItem(viewModel) {
                    self.presenter.didToggleTaskCompletion(
                        at: index,
                        isCompleted: !viewModel.isCompleted
                    )
                }
            }

            return cell
        }
        return ds
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .systemYellow
        return indicator
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.isHidden = true
        return label
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refresh.tintColor = .systemYellow
        return refresh
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomBarHeightConstraint.constant = 56 + view.safeAreaInsets.bottom
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.view.backgroundColor = .systemBackground

        title = "Задачи"
        navigationController?.navigationBar.prefersLargeTitles = true

        searchContainer.translatesAutoresizingMaskIntoConstraints = false
        searchContainer.backgroundColor = .systemBackground
        view.addSubview(searchContainer)
        searchContainer.addSubview(searchBar)

        tableView.refreshControl = refreshControl
        view.addSubview(tableView)

        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)

        view.addSubview(emptyStateLabel)
        view.addSubview(activityIndicator)

        if #available(iOS 13.0, *) {
            let tf = searchBar.searchTextField
            tf.backgroundColor = .secondarySystemBackground
            tf.textColor = .label
            tf.leftView?.tintColor = .secondaryLabel
            tf.clearButtonMode = .never // крестик только когда начнем вводить
            tf.attributedPlaceholder = NSAttributedString(
                string: "Поиск задач",
                attributes: [.foregroundColor: UIColor.secondaryLabel]
            )
        }

        bottomBarHeightConstraint = bottomBar.heightAnchor.constraint(equalToConstant: 56)
        bottomBarHeightConstraint.isActive = true

        NSLayoutConstraint.activate([
            searchContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            searchBar.topAnchor.constraint(equalTo: searchContainer.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -12),
            searchBar.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: -8),

            tableView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        bottomBar.onAddButtonTapped = { [weak self] in
            self?.presenter.didTapAddTask()
        }

        definesPresentationContext = true
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        presenter.didPullToRefresh()
    }

    // MARK: - Sharing

    private func shareTask(viewModel: TaskViewModel) {
        var textToShare = viewModel.title

        if let description = viewModel.description {
            textToShare += "\n\n" + description
        }

        textToShare += "\n\n📅 " + viewModel.createdDateString
        textToShare += "\n" + (viewModel.isCompleted ? "✅ Выполнено" : "⏳ В процессе")

        let activityVC = UIActivityViewController(
            activityItems: [textToShare],
            applicationActivities: nil
        )

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY - 80, width: 1, height: 1)
        }

        present(activityVC, animated: true)
    }
}

// MARK: - TaskListViewInput

extension TaskListViewController: TaskListViewInput {

    func displayTasks(_ viewModels: [TaskViewModel]) {
        emptyStateLabel.isHidden = true
        tableView.isHidden = false

        var snapshot = NSDiffableDataSourceSnapshot<Section, TaskViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModels)
        dataSource.apply(snapshot, animatingDifferences: true)

        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }

        bottomBar.updateTasksCount(viewModels.count)
    }

    func showLoading() {
        ThreadSafetyHelpers.assertMainThread()

        emptyStateLabel.isHidden = true
        activityIndicator.startAnimating()
    }

    func hideLoading() {
        ThreadSafetyHelpers.assertMainThread()

        activityIndicator.stopAnimating()

        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    func showError(message: String) {
        ThreadSafetyHelpers.assertMainThread()

        hideLoading()

        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        present(alert, animated: true)
    }

    func showEmptyState(message: String) {
        ThreadSafetyHelpers.assertMainThread()

        tableView.isHidden = false
        activityIndicator.stopAnimating()

        emptyStateLabel.text = message
        emptyStateLabel.isHidden = false

        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, TaskViewModel>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: true)

        bottomBar.updateTasksCount(0)
    }
}

// MARK: - UITableViewDelegate

extension TaskListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let viewModel = dataSource.itemIdentifier(for: indexPath) else { return }
        let snapshot = dataSource.snapshot()
        guard let index = snapshot.indexOfItem(viewModel) else { return }

        presenter.didSelectTask(at: index)
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        guard let viewModel = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let snapshot = dataSource.snapshot()
        guard let index = snapshot.indexOfItem(viewModel) else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(
                title: "Редактировать",
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in
                self?.presenter.didSelectTask(at: index)
            }

            let shareAction = UIAction(
                title: "Поделиться",
                image: UIImage(systemName: "square.and.arrow.up")
            ) { [weak self] _ in
                self?.shareTask(viewModel: viewModel)
            }

            let deleteAction = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.presenter.didRequestDeleteTask(at: index)
            }

            return UIMenu(title: viewModel.title, children: [editAction, shareAction, deleteAction])
        }
    }
}

// MARK: - UISearchBarDelegate

extension TaskListViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.clearButtonMode = searchText.isEmpty ? .never : .whileEditing
        }
        presenter.didChangeSearchQuery(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        presenter.didChangeSearchQuery("")
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
