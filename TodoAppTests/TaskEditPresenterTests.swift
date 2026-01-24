//
//  TaskEditPresenterTests.swift
//  TodoAppTests
//
//  Created by Тадевос Курдоглян on 24.01.2026.
//

import XCTest
@testable import TodoApp

final class TaskEditPresenterTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: TaskEditPresenter!
    var mockView: MockTaskEditView!
    var mockInteractor: MockTaskEditInteractor!
    var mockRouter: MockTaskEditRouter!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        mockView = MockTaskEditView()
        mockInteractor = MockTaskEditInteractor()
        mockRouter = MockTaskEditRouter()
    }
    
    override func tearDown() {
        sut = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        
        super.tearDown()
    }
    
    // MARK: - Helper
    
    private func createSUT(task: TaskEntity? = nil) {
        sut = TaskEditPresenter(task: task)
        sut.view = mockView
        sut.interactor = mockInteractor
        sut.router = mockRouter
    }
    
    // MARK: - Tests: viewDidLoad (Create Mode)
    
    func testViewDidLoad_CreateMode_DoesNotFillForm() {
        // Arrange
        createSUT(task: nil) // Режим создания
        
        // Act
        sut.viewDidLoad()
        
        // Assert
        XCTAssertFalse(mockView.displayTaskCalled, "В режиме создания форма не должна заполняться")
    }
    
    // MARK: - Tests: viewDidLoad (Edit Mode)
    
    func testViewDidLoad_EditMode_FillsForm() {
        // Arrange
        let task = TaskEntity(
            id: 1,
            title: "Existing Task",
            taskDescription: "Some description",
            createdDate: Date(),
            isCompleted: false
        )
        createSUT(task: task) // Режим редактирования
        
        // Act
        sut.viewDidLoad()
        
        // Assert
        XCTAssertTrue(mockView.displayTaskCalled, "В режиме редактирования форма должна заполниться")
        XCTAssertEqual(mockView.lastDisplayedTitle, "Existing Task")
        XCTAssertEqual(mockView.lastDisplayedDescription, "Some description")
    }
    
    func testViewDidLoad_EditMode_TaskWithoutDescription() {
        // Arrange
        let task = TaskEntity(
            id: 1,
            title: "Task without description",
            taskDescription: nil,
            createdDate: Date(),
            isCompleted: false
        )
        createSUT(task: task)
        
        // Act
        sut.viewDidLoad()
        
        // Assert
        XCTAssertTrue(mockView.displayTaskCalled)
        XCTAssertEqual(mockView.lastDisplayedTitle, "Task without description")
        XCTAssertNil(mockView.lastDisplayedDescription)
    }
    
    // MARK: - Tests: didTapSave (Create Mode)
    
    func testDidTapSave_CreateMode_ValidData_CreatesTask() {
        // Arrange
        createSUT(task: nil)
        
        // Act
        sut.didTapSave(title: "New Task", description: "Description")
        
        // Assert
        XCTAssertTrue(mockView.showLoadingCalled, "Должен показать индикатор загрузки")
        XCTAssertTrue(mockInteractor.createTaskCalled, "Interactor должен создать задачу")
        XCTAssertEqual(mockInteractor.lastCreatedTitle, "New Task")
        XCTAssertEqual(mockInteractor.lastCreatedDescription, "Description")
    }
    
    func testDidTapSave_CreateMode_EmptyTitle_ShowsError() {
        // Arrange
        createSUT(task: nil)
        
        // Act
        sut.didTapSave(title: "", description: "Description")
        
        // Assert
        XCTAssertFalse(mockView.showLoadingCalled, "Не должен показывать индикатор")
        XCTAssertFalse(mockInteractor.createTaskCalled, "Не должен вызывать interactor")
        XCTAssertTrue(mockView.showErrorCalled, "Должна показать ошибку валидации")
        XCTAssertTrue(mockView.lastErrorMessage?.contains("пустым") ?? false)
    }
    
    func testDidTapSave_CreateMode_WhitespaceTitle_ShowsError() {
        // Arrange
        createSUT(task: nil)
        
        // Act
        sut.didTapSave(title: "   ", description: "Description")
        
        // Assert
        XCTAssertTrue(mockView.showErrorCalled, "Должна показать ошибку для пробелов")
        XCTAssertFalse(mockInteractor.createTaskCalled)
    }
    
    func testDidTapSave_CreateMode_TrimsWhitespace() {
        // Arrange
        createSUT(task: nil)
        
        // Act
        sut.didTapSave(title: "  Task Title  ", description: "  Description  ")
        
        // Assert
        XCTAssertTrue(mockInteractor.createTaskCalled)
        XCTAssertEqual(mockInteractor.lastCreatedTitle, "Task Title", "Должен обрезать пробелы")
        XCTAssertEqual(mockInteractor.lastCreatedDescription, "Description", "Должен обрезать пробелы")
    }
    
    func testDidTapSave_CreateMode_EmptyDescription_SavesAsNil() {
        // Arrange
        createSUT(task: nil)
        
        // Act
        sut.didTapSave(title: "Task", description: "   ")
        
        // Assert
        XCTAssertTrue(mockInteractor.createTaskCalled)
        XCTAssertNil(mockInteractor.lastCreatedDescription, "Пустое описание должно быть nil")
    }
    
    // MARK: - Tests: didTapSave (Edit Mode)
    
    func testDidTapSave_EditMode_ValidData_UpdatesTask() {
        // Arrange
        let originalTask = TaskEntity(
            id: 1,
            title: "Original",
            taskDescription: "Original Desc",
            createdDate: Date(),
            isCompleted: false
        )
        createSUT(task: originalTask)
        
        // Act
        sut.didTapSave(title: "Updated Title", description: "Updated Description")
        
        // Assert
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertTrue(mockInteractor.updateTaskCalled, "Interactor должен обновить задачу")
        XCTAssertEqual(mockInteractor.lastUpdatedTask?.id, 1, "ID должен сохраниться")
        XCTAssertEqual(mockInteractor.lastUpdatedTask?.title, "Updated Title")
        XCTAssertEqual(mockInteractor.lastUpdatedTask?.taskDescription, "Updated Description")
    }
    
    func testDidTapSave_EditMode_PreservesOriginalFields() {
        // Arrange
        let originalDate = Date(timeIntervalSince1970: 1000000)
        let originalTask = TaskEntity(
            id: 123,
            title: "Original",
            taskDescription: "Desc",
            createdDate: originalDate,
            isCompleted: true
        )
        createSUT(task: originalTask)
        
        // Act
        sut.didTapSave(title: "New Title", description: "New Desc")
        
        // Assert
        XCTAssertEqual(mockInteractor.lastUpdatedTask?.id, 123, "ID должен сохраниться")
        XCTAssertEqual(mockInteractor.lastUpdatedTask?.createdDate, originalDate, "Дата создания должна сохраниться")
        XCTAssertEqual(mockInteractor.lastUpdatedTask?.isCompleted, true, "Статус должен сохраниться")
    }
    
    // MARK: - Tests: didTapCancel
    
    func testDidTapCancel_ClosesScreen() {
        // Arrange
        createSUT(task: nil)
        
        // Act
        sut.didTapCancel()
        
        // Assert
        XCTAssertTrue(mockRouter.closeCalled, "Router должен закрыть экран")
    }
    
    // MARK: - Tests: didCreateTask (from Interactor)
    
    func testDidCreateTask_Success_ClosesScreen() {
        // Arrange
        createSUT(task: nil)
        let createdTask = TaskEntity(
            id: 1,
            title: "New Task",
            taskDescription: nil,
            createdDate: Date(),
            isCompleted: false
        )
        
        // Act
        sut.didCreateTask(createdTask)
        
        // Assert
        XCTAssertTrue(mockView.hideLoadingCalled, "Должен скрыть индикатор")
        XCTAssertTrue(mockRouter.closeCalled, "Должен закрыть экран после успешного создания")
    }
    
    // MARK: - Tests: didFailToCreateTask
    
    func testDidFailToCreateTask_ShowsError() {
        // Arrange
        createSUT(task: nil)
        let error = TestError(message: "Creation failed")
        
        // Act
        sut.didFailToCreateTask(with: error)
        
        // Assert
        XCTAssertTrue(mockView.hideLoadingCalled, "Должен скрыть индикатор")
        XCTAssertTrue(mockView.showErrorCalled, "Должна показать ошибку")
        XCTAssertNotNil(mockView.lastErrorMessage)
        XCTAssertFalse(mockRouter.closeCalled, "Не должен закрывать экран при ошибке")
    }
    
    // MARK: - Tests: didUpdateTask (from Interactor)
    
    func testDidUpdateTask_Success_ClosesScreen() {
        // Arrange
        let task = TaskEntity(
            id: 1,
            title: "Task",
            taskDescription: nil,
            createdDate: Date(),
            isCompleted: false
        )
        createSUT(task: task)
        
        let updatedTask = TaskEntity(
            id: 1,
            title: "Updated Task",
            taskDescription: "New Desc",
            createdDate: task.createdDate,
            isCompleted: true
        )
        
        // Act
        sut.didUpdateTask(updatedTask)
        
        // Assert
        XCTAssertTrue(mockView.hideLoadingCalled, "Должен скрыть индикатор")
        XCTAssertTrue(mockRouter.closeCalled, "Должен закрыть экран после успешного обновления")
    }
    
    // MARK: - Tests: didFailToUpdateTask
    
    func testDidFailToUpdateTask_ShowsError() {
        // Arrange
        let task = TaskEntity(
            id: 1,
            title: "Task",
            taskDescription: nil,
            createdDate: Date(),
            isCompleted: false
        )
        createSUT(task: task)
        let error = TestError(message: "Update failed")
        
        // Act
        sut.didFailToUpdateTask(with: error)
        
        // Assert
        XCTAssertTrue(mockView.hideLoadingCalled, "Должен скрыть индикатор")
        XCTAssertTrue(mockView.showErrorCalled, "Должна показать ошибку")
        XCTAssertNotNil(mockView.lastErrorMessage)
        XCTAssertFalse(mockRouter.closeCalled, "Не должен закрывать экран при ошибке")
    }
}
