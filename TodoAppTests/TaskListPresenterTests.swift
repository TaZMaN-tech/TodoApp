//
//  TaskListPresenterTests.swift
//  TodoAppTests
//
//  Created by Тадевос Курдоглян on 24.01.2026.
//

import XCTest
@testable import TodoApp

final class TaskListPresenterTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: TaskListPresenter!
    var mockView: MockTaskListView!
    var mockInteractor: MockTaskListInteractor!
    var mockRouter: MockTaskListRouter!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        sut = TaskListPresenter()
        mockView = MockTaskListView()
        mockInteractor = MockTaskListInteractor()
        mockRouter = MockTaskListRouter()
        
        sut.view = mockView
        sut.interactor = mockInteractor
        sut.router = mockRouter
    }
    
    override func tearDown() {
        sut = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests: viewDidLoad
    
    func testViewDidLoad_LoadsInitialData() {
        // Act
        sut.viewDidLoad()
        
        // Assert
        XCTAssertTrue(mockView.showLoadingCalled, "View должна показать индикатор загрузки")
        XCTAssertTrue(mockInteractor.loadInitialDataIfNeededCalled, "Interactor должен загрузить начальные данные")
    }
    
    // MARK: - Tests: didSelectTask
    
    func testDidSelectTask_OpensEditScreen() {
        // Arrange
        let task = TaskEntity(id: 1, title: "Test", taskDescription: nil, createdDate: Date(), isCompleted: false)
        let viewModel = createViewModel(from: task)
        
        sut.didLoadTasks([task])
        
        // Act
        sut.didSelectTask(at: 0)
        
        // Assert
        XCTAssertTrue(mockRouter.openEditTaskCalled, "Router должен открыть экран редактирования")
        XCTAssertEqual(mockRouter.lastEditedTask?.id, 1)
    }
    
    func testDidSelectTask_InvalidIndex_DoesNothing() {
        // Arrange
        sut.didLoadTasks([])
        
        // Act
        sut.didSelectTask(at: 10) // Некорректный индекс
        
        // Assert
        XCTAssertFalse(mockRouter.openEditTaskCalled, "Router не должен быть вызван для некорректного индекса")
    }
    
    // MARK: - Tests: didRequestDeleteTask
    
    func testDidRequestDeleteTask_CallsInteractor() {
        // Arrange
        let task = TaskEntity(id: 123, title: "Test", taskDescription: nil, createdDate: Date(), isCompleted: false)
        sut.didLoadTasks([task])
        
        // Act
        sut.didRequestDeleteTask(at: 0)
        
        // Assert
        XCTAssertTrue(mockInteractor.deleteTaskCalled, "Interactor должен быть вызван для удаления")
        XCTAssertEqual(mockInteractor.lastDeletedTaskId, 123)
    }
    
    // MARK: - Tests: didToggleTaskCompletion
    
    func testDidToggleTaskCompletion_UpdatesTaskStatus() {
        // Arrange
        let task = TaskEntity(id: 1, title: "Test", taskDescription: nil, createdDate: Date(), isCompleted: false)
        sut.didLoadTasks([task])
        
        // Act
        sut.didToggleTaskCompletion(at: 0, isCompleted: true)
        
        // Assert
        XCTAssertTrue(mockView.displayTasksCalled, "View должна обновиться (оптимистичное обновление)")
        XCTAssertTrue(mockInteractor.updateTaskCompletionCalled, "Interactor должен обновить задачу")
        XCTAssertEqual(mockInteractor.lastUpdatedTaskId, 1)
        XCTAssertEqual(mockInteractor.lastUpdatedIsCompleted, true)
    }
    
    // MARK: - Tests: didChangeSearchQuery
    
    func testDidChangeSearchQuery_EmptyQuery_LoadsAllTasks() {
        // Act
        sut.didChangeSearchQuery("")
        
        // Assert
        XCTAssertTrue(mockInteractor.loadTasksCalled, "Должен загрузить все задачи для пустого запроса")
        XCTAssertFalse(mockInteractor.searchTasksCalled, "Поиск не должен вызываться")
    }
    
    func testDidChangeSearchQuery_NonEmptyQuery_SearchesTasks() {
        // Act
        sut.didChangeSearchQuery("test query")
        
        // Assert
        XCTAssertTrue(mockInteractor.searchTasksCalled, "Должен вызвать поиск")
        XCTAssertEqual(mockInteractor.lastSearchQuery, "test query")
        XCTAssertFalse(mockInteractor.loadTasksCalled, "Загрузка всех не должна вызываться")
    }
    
    func testDidChangeSearchQuery_TrimsWhitespace() {
        // Act
        sut.didChangeSearchQuery("  query  ")
        
        // Assert
        XCTAssertTrue(mockInteractor.searchTasksCalled)
        XCTAssertEqual(mockInteractor.lastSearchQuery, "query", "Должен обрезать пробелы")
    }
    
    // MARK: - Tests: didTapAddTask
    
    func testDidTapAddTask_OpensCreateScreen() {
        // Act
        sut.didTapAddTask()
        
        // Assert
        XCTAssertTrue(mockRouter.openCreateTaskCalled, "Router должен открыть экран создания")
    }
    
    // MARK: - Tests: didLoadTasks (from Interactor)
    
    func testDidLoadTasks_DisplaysViewModels() {
        // Arrange
        let tasks = [
            TaskEntity(id: 1, title: "Task 1", taskDescription: "Desc 1", createdDate: Date(), isCompleted: false),
            TaskEntity(id: 2, title: "Task 2", taskDescription: nil, createdDate: Date(), isCompleted: true)
        ]
        
        // Act
        sut.didLoadTasks(tasks)
        
        // Assert
        XCTAssertTrue(mockView.hideLoadingCalled, "Должен скрыть индикатор загрузки")
        XCTAssertTrue(mockView.displayTasksCalled, "Должен отобразить задачи")
        XCTAssertEqual(mockView.lastDisplayedViewModels?.count, 2)
        XCTAssertEqual(mockView.lastDisplayedViewModels?.first?.title, "Task 1")
    }
    
    func testDidLoadTasks_EmptyList_ShowsEmptyState() {
        // Act
        sut.didLoadTasks([])
        
        // Assert
        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertTrue(mockView.showEmptyStateCalled, "Должно показать пустое состояние")
        XCTAssertNotNil(mockView.lastEmptyStateMessage)
    }
    
    func testDidLoadTasks_EmptySearchResults_ShowsSearchEmptyState() {
        // Arrange
        sut.didChangeSearchQuery("nonexistent")
        
        // Act
        sut.didLoadTasks([])
        
        // Assert
        XCTAssertTrue(mockView.showEmptyStateCalled)
        XCTAssertTrue(mockView.lastEmptyStateMessage?.contains("nonexistent") ?? false, "Сообщение должно содержать поисковый запрос")
    }
    
    // MARK: - Tests: didFailToLoadTasks
    
    func testDidFailToLoadTasks_ShowsError() {
        // Arrange
        let error = TestError(message: "Network error")
        
        // Act
        sut.didFailToLoadTasks(with: error)
        
        // Assert
        XCTAssertTrue(mockView.hideLoadingCalled, "Должен скрыть индикатор")
        XCTAssertTrue(mockView.showErrorCalled, "Должна показать ошибку")
        XCTAssertNotNil(mockView.lastErrorMessage)
    }
    
    // MARK: - Tests: didDeleteTask
    
    func testDidDeleteTask_RemovesFromList() {
        // Arrange
        let tasks = [
            TaskEntity(id: 1, title: "Task 1", taskDescription: nil, createdDate: Date(), isCompleted: false),
            TaskEntity(id: 2, title: "Task 2", taskDescription: nil, createdDate: Date(), isCompleted: false)
        ]
        sut.didLoadTasks(tasks)
        
        // Act
        sut.didDeleteTask(taskId: 1)
        
        // Assert
        XCTAssertTrue(mockView.displayTasksCalled, "View должна обновиться")
        XCTAssertEqual(mockView.lastDisplayedViewModels?.count, 1, "Должна остаться одна задача")
        XCTAssertEqual(mockView.lastDisplayedViewModels?.first?.id, 2)
    }
    
    func testDidDeleteTask_LastTask_ShowsEmptyState() {
        // Arrange
        let task = TaskEntity(id: 1, title: "Task 1", taskDescription: nil, createdDate: Date(), isCompleted: false)
        sut.didLoadTasks([task])
        
        // Act
        sut.didDeleteTask(taskId: 1)
        
        // Assert
        XCTAssertTrue(mockView.showEmptyStateCalled, "Должно показать пустое состояние")
    }
    
    // MARK: - Helpers
    
    private func createViewModel(from entity: TaskEntity) -> TaskViewModel {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        return TaskViewModel(
            id: entity.id,
            title: entity.title,
            description: entity.taskDescription,
            createdDateString: dateFormatter.string(from: entity.createdDate),
            isCompleted: entity.isCompleted,
            entity: entity
        )
    }
}
