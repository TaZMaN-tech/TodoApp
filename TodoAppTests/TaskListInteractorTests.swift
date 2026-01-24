//
//  TaskListInteractorTests.swift
//  TodoAppTests
//
//  Created by Тадевос Курдоглян on 24.01.2026.
//

import XCTest
@testable import TodoApp

final class TaskListInteractorTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: TaskListInteractor!
    var mockRepository: MockTaskRepository!
    var mockNetworkService: NetworkService!
    var mockPresenter: MockTaskListInteractorOutput!
    var mockUserDefaults: UserDefaults!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        mockRepository = MockTaskRepository()
        mockNetworkService = NetworkService()
        mockPresenter = MockTaskListInteractorOutput()
        
        mockUserDefaults = UserDefaults(suiteName: "TestDefaults")!
        mockUserDefaults.removePersistentDomain(forName: "TestDefaults")
        
        sut = TaskListInteractor(
            repository: mockRepository,
            networkService: mockNetworkService,
            userDefaults: mockUserDefaults
        )
        sut.presenter = mockPresenter
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockNetworkService = nil
        mockPresenter = nil
        mockUserDefaults.removePersistentDomain(forName: "TestDefaults")
        mockUserDefaults = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests: loadTasks
    
    func testLoadTasks_Success() {
        // Arrange
        let expectedTasks = [
            TaskEntity(id: 1, title: "Task 1", taskDescription: "Description 1", createdDate: Date(), isCompleted: false),
            TaskEntity(id: 2, title: "Task 2", taskDescription: nil, createdDate: Date(), isCompleted: true)
        ]
        mockRepository.tasksToReturn = expectedTasks
        
        // Act
        sut.loadTasks()
        
        // Assert
        XCTAssertTrue(mockRepository.fetchAllCalled, "Repository fetchAll должен быть вызван")
        XCTAssertTrue(mockPresenter.didLoadTasksCalled, "Presenter didLoadTasks должен быть вызван")
        XCTAssertEqual(mockPresenter.lastLoadedTasks?.count, 2, "Должно быть загружено 2 задачи")
        XCTAssertEqual(mockPresenter.lastLoadedTasks?.first?.id, 1)
    }
    
    func testLoadTasks_Failure() {
        // Arrange
        let expectedError = TestError(message: "Database error")
        mockRepository.errorToReturn = expectedError
        
        // Act
        sut.loadTasks()
        
        // Assert
        XCTAssertTrue(mockRepository.fetchAllCalled, "Repository fetchAll должен быть вызван")
        XCTAssertTrue(mockPresenter.didFailToLoadTasksCalled, "Presenter didFailToLoadTasks должен быть вызван")
        XCTAssertNotNil(mockPresenter.lastLoadError)
    }
    
    // MARK: - Tests: searchTasks
    
    func testSearchTasks_Success() {
        // Arrange
        let allTasks = [
            TaskEntity(id: 1, title: "Buy groceries", taskDescription: "Milk and bread", createdDate: Date(), isCompleted: false),
            TaskEntity(id: 2, title: "Write report", taskDescription: "Q4 report", createdDate: Date(), isCompleted: false),
            TaskEntity(id: 3, title: "Buy tickets", taskDescription: "Concert tickets", createdDate: Date(), isCompleted: false)
        ]
        mockRepository.tasksToReturn = allTasks
        
        // Act
        sut.searchTasks(query: "buy")
        
        // Assert
        XCTAssertTrue(mockRepository.searchCalled, "Repository search должен быть вызван")
        XCTAssertEqual(mockRepository.lastSearchQuery, "buy")
        XCTAssertTrue(mockPresenter.didLoadTasksCalled, "Presenter didLoadTasks должен быть вызван")
        XCTAssertEqual(mockPresenter.lastLoadedTasks?.count, 2, "Должно найтись 2 задачи с 'buy'")
    }
    
    func testSearchTasks_EmptyQuery() {
        // Arrange
        mockRepository.tasksToReturn = []
        
        // Act
        sut.searchTasks(query: "nonexistent")
        
        // Assert
        XCTAssertTrue(mockRepository.searchCalled)
        XCTAssertEqual(mockPresenter.lastLoadedTasks?.count, 0, "Должно быть 0 результатов")
    }
    
    // MARK: - Tests: deleteTask
    
    func testDeleteTask_Success() {
        // Arrange
        let taskId: Int64 = 123
        
        // Act
        sut.deleteTask(taskId: taskId)
        
        // Assert
        XCTAssertTrue(mockRepository.deleteCalled, "Repository delete должен быть вызван")
        XCTAssertEqual(mockRepository.lastDeletedTaskId, taskId)
        XCTAssertTrue(mockPresenter.didDeleteTaskCalled, "Presenter didDeleteTask должен быть вызван")
        XCTAssertEqual(mockPresenter.lastDeletedTaskId, taskId)
    }
    
    func testDeleteTask_Failure() {
        // Arrange
        let taskId: Int64 = 123
        let expectedError = TestError(message: "Delete failed")
        mockRepository.errorToReturn = expectedError
        
        // Act
        sut.deleteTask(taskId: taskId)
        
        // Assert
        XCTAssertTrue(mockRepository.deleteCalled)
        XCTAssertTrue(mockPresenter.didFailToDeleteTaskCalled, "Presenter didFailToDeleteTask должен быть вызван")
        XCTAssertNotNil(mockPresenter.lastDeleteError)
    }
    
    // MARK: - Tests: updateTaskCompletion
    
    func testUpdateTaskCompletion_Success() {
        // Arrange
        let task = TaskEntity(
            id: 1,
            title: "Test Task",
            taskDescription: "Description",
            createdDate: Date(),
            isCompleted: false
        )
        mockRepository.tasksToReturn = [task]
        
        // Act
        sut.updateTaskCompletion(taskId: 1, isCompleted: true)
        
        // Assert
        XCTAssertTrue(mockRepository.fetchAllCalled, "Должен загрузить задачи для получения полных данных")
        
        XCTAssertTrue(mockRepository.updateCalled, "Repository update должен быть вызван")
        XCTAssertEqual(mockRepository.lastUpdatedTask?.id, 1)
        XCTAssertEqual(mockRepository.lastUpdatedTask?.isCompleted, true, "Статус должен быть обновлён")
        
        XCTAssertTrue(mockPresenter.didUpdateTaskCalled)
    }
    
    func testUpdateTaskCompletion_TaskNotFound() {
        // Arrange
        mockRepository.tasksToReturn = [] // Нет задач
        
        // Act
        sut.updateTaskCompletion(taskId: 999, isCompleted: true)
        
        // Assert
        XCTAssertTrue(mockRepository.fetchAllCalled)
        XCTAssertFalse(mockRepository.updateCalled, "Update не должен быть вызван для несуществующей задачи")
        XCTAssertTrue(mockPresenter.didFailToUpdateTaskCalled, "Должна быть ошибка")
    }
    
    // MARK: - Tests: loadInitialDataIfNeeded
    
    func testLoadInitialDataIfNeeded_FirstLaunch() {
        // Arrange
        XCTAssertFalse(mockUserDefaults.bool(forKey: "TaskList.isFirstLaunch"), "Должен быть первый запуск")
        
        // Act
        sut.loadInitialDataIfNeeded()
        
        // Assert
        XCTAssertTrue(mockPresenter.didStartLoadingCalled, "Должен показать индикатор загрузки")
    }
    
    func testLoadInitialDataIfNeeded_NotFirstLaunch() {
        // Arrange
        mockUserDefaults.set(true, forKey: "TaskList.isFirstLaunch")
        let expectedTasks = [
            TaskEntity(id: 1, title: "Existing Task", taskDescription: nil, createdDate: Date(), isCompleted: false)
        ]
        mockRepository.tasksToReturn = expectedTasks
        
        // Act
        sut.loadInitialDataIfNeeded()
        
        // Assert
        XCTAssertTrue(mockRepository.fetchAllCalled, "Должен загрузить из локальной базы")
        XCTAssertFalse(mockPresenter.didStartLoadingCalled, "Не должен показывать индикатор для сетевой загрузки")
        XCTAssertTrue(mockPresenter.didLoadTasksCalled)
    }
}

// MARK: - Mock TaskListInteractorOutput

class MockTaskListInteractorOutput: TaskListInteractorOutput {
    
    var didLoadTasksCalled = false
    var lastLoadedTasks: [TaskEntity]?
    
    var didFailToLoadTasksCalled = false
    var lastLoadError: Error?
    
    var didDeleteTaskCalled = false
    var lastDeletedTaskId: Int64?
    
    var didFailToDeleteTaskCalled = false
    var lastDeleteError: Error?
    
    var didUpdateTaskCalled = false
    var lastUpdatedTask: TaskEntity?
    
    var didFailToUpdateTaskCalled = false
    var lastUpdateError: Error?
    
    var didStartLoadingCalled = false
    var didFinishLoadingCalled = false
    
    func didLoadTasks(_ tasks: [TaskEntity]) {
        didLoadTasksCalled = true
        lastLoadedTasks = tasks
    }
    
    func didFailToLoadTasks(with error: Error) {
        didFailToLoadTasksCalled = true
        lastLoadError = error
    }
    
    func didDeleteTask(taskId: Int64) {
        didDeleteTaskCalled = true
        lastDeletedTaskId = taskId
    }
    
    func didFailToDeleteTask(with error: Error) {
        didFailToDeleteTaskCalled = true
        lastDeleteError = error
    }
    
    func didUpdateTask(_ task: TaskEntity) {
        didUpdateTaskCalled = true
        lastUpdatedTask = task
    }
    
    func didFailToUpdateTask(with error: Error) {
        didFailToUpdateTaskCalled = true
        lastUpdateError = error
    }
    
    func didStartLoading() {
        didStartLoadingCalled = true
    }
    
    func didFinishLoading() {
        didFinishLoadingCalled = true
    }
}
