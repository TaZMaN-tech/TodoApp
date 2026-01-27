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
    var onTasksCountChanged: ((Int) -> Void)?
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseIdentifier)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        table.separatorStyle = .singleLine
        table.backgroundColor = .systemBackground
        return table
    }()
    
    /// Diffable Data Source для таблицы
    private lazy var dataSource: UITableViewDiffableDataSource<Section, TaskViewModel> = {
        let dataSource = UITableViewDiffableDataSource<Section, TaskViewModel>(
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
                if let currentSnapshot = self?.dataSource.snapshot(),
                   let index = currentSnapshot.indexOfItem(viewModel) {
                    self?.presenter.didToggleTaskCompletion(
                        at: index,
                        isCompleted: !viewModel.isCompleted
                    )
                }
            }
            
            return cell
        }
        
        return dataSource
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Поиск задач"
        controller.searchBar.delegate = self
        return controller
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
    
    // MARK: - Private Properties
    
    private var viewModels: [TaskViewModel] = []
    
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
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyStateLabel)
        
        tableView.refreshControl = refreshControl
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
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
        
        present(activityVC, animated: true)
    }
}

// MARK: - TaskListViewInput

extension TaskListViewController: TaskListViewInput {
    
    func displayTasks(_ viewModels: [TaskViewModel]) {
        emptyStateLabel.isHidden = true
        
        tableView.isHidden = false
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, TaskViewModel>()
        snapshot.appendSections([Section.main])
        snapshot.appendItems(viewModels)
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        onTasksCountChanged?(viewModels.count)
    }
    
    func showLoading() {
        ThreadSafetyHelpers.assertMainThread()
        
        if dataSource.snapshot().numberOfItems == 0 && !refreshControl.isRefreshing {
            activityIndicator.startAnimating()
            tableView.isHidden = true
            emptyStateLabel.isHidden = true
        }
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
        
        tableView.isHidden = true
        activityIndicator.stopAnimating()
        
        emptyStateLabel.text = message
        emptyStateLabel.isHidden = false
        
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        onTasksCountChanged?(0)
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

// MARK: - UISearchResultsUpdating

extension TaskListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        presenter.didChangeSearchQuery(searchText)
    }
}

// MARK: - UISearchBarDelegate

extension TaskListViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.didChangeSearchQuery("")
    }
}
