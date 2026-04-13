//
//  TaskListView.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 13.04.2026.
//

import SwiftUI

struct TaskListView: View {

    // @State — владелец ViewModel. Аналог @StateObject, но для @Observable.
    // Именно @State создаёт и хранит объект — не пересоздаёт при перерисовке.
    @State private var viewModel: TaskListViewModel

    // @State для локального UI-состояния — показывать ли sheet создания задачи
    @State private var showingCreateTask = false

    init(viewModel: TaskListViewModel) {
        // _viewModel — обращение к State обёртке напрямую, чтобы передать начальное значение
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Задачи")
                .searchable(
                    text: $viewModel.searchQuery,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Поиск задач"
                )
                .toolbar { toolbarContent }
                .sheet(isPresented: $showingCreateTask) {
                    CreateTaskView(viewModel: viewModel)
                }
        }
        // .task — SwiftUI аналог viewDidLoad + автоматическая отмена при исчезновении View
        // Привязан к lifecycle View, не нужен deinit/cancel
        .task {
            await viewModel.loadInitialDataIfNeeded()
        }
        // Реагируем на изменение searchQuery с debounce
        .onChange(of: viewModel.searchQuery) {
            Task { await viewModel.loadTasks() }
        }
    }

    // MARK: - Content

    // Computed property вместо огромного body — читаемость важнее краткости
    @ViewBuilder
    private var content: some View {
        switch (viewModel.isLoading, viewModel.tasks.isEmpty, viewModel.errorMessage) {

        case (true, _, _):
            loadingView

        case (_, _, let msg?) where !viewModel.isLoading:
            errorView(message: msg)

        case (_, true, _):
            emptyView

        default:
            taskList
        }
    }

    // MARK: - States

    private var loadingView: some View {
        ProgressView("Загрузка...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView(
            "Что-то пошло не так",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
        // ContentUnavailableView — нативный iOS 17 компонент для empty/error состояний
        .overlay(alignment: .bottom) {
            Button("Повторить") {
                Task { await viewModel.loadTasks() }
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 40)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            viewModel.searchQuery.isEmpty ? "Нет задач" : "Ничего не найдено",
            systemImage: viewModel.searchQuery.isEmpty ? "checklist" : "magnifyingglass",
            description: Text(
                viewModel.searchQuery.isEmpty
                    ? "Нажми + чтобы создать первую задачу"
                    : "Попробуй другой запрос"
            )
        )
    }

    // MARK: - Task List

    private var taskList: some View {
        // List — это UITableView под капотом, но декларативный
        // ForEach по [TaskItem] — @Model классы Identifiable автоматически
        List {
            ForEach(viewModel.tasks) { item in
                // NavigationLink с value — не создаёт destination сразу,
                // только когда пользователь тапает. Эффективнее чем старый NavigationLink(destination:)
                NavigationLink(value: item) {
                    TaskRowView(item: item) {
                        Task { await viewModel.toggleCompletion(item) }
                    }
                }
                // swipeActions заменяет contextMenuConfigurationForRowAt
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task { await viewModel.delete(item) }
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            // .refreshable автоматически показывает pull-to-refresh индикатор
            await viewModel.loadTasks()
        }
        // navigationDestination — регистрирует destination для типа TaskItem
        // Вся навигация в одном месте, не размазана по ячейкам
        .navigationDestination(for: TaskItem.self) { item in
            TaskDetailView(item: item, viewModel: viewModel)
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showingCreateTask = true
            } label: {
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(.yellow)
            }
        }

        // Счётчик задач — аналог BottomBarView
        ToolbarItem(placement: .bottomBar) {
            Text(viewModel.tasks.count.taskCountString)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
