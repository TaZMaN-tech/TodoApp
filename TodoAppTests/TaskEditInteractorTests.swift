//
//  TaskEditInteractorTests.swift
//  TodoAppTests
//
//  Created by Тадевос Курдоглян on 24.01.2026.
//

import XCTest
@testable import TodoApp

final class TaskEditInteractorTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: TaskEditInteractor!
    var mockRepository: MockTaskRepository!
    var mockPresenter: MockTaskEditInteractorOutput!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        mockRepository = MockTaskRepository()
        mockPresenter = MockTaskEditInteractorOutput()
        
        sut = TaskEditInteractor(repository: mockRepository)
        sut.presenter = mockPresenter
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockPresenter = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests: createTask
    
    func testCreateTask_Success() {
        // Arrange
        let title = "New Task"
        let description = "Task description"
        
        // Act
        sut.createTask(title: title, description: description)
        
        // Assert
        XCTAssertTrue(mockRepository.createCalled, "Repository create должен быть вызван")
        XCTAssertEqual(mockRepository.lastCreatedTask?.title, title)
        XCTAssertEqual(mockRepository.lastCreatedTask?.taskDescription, description)
        XCTAssertFalse(mockRepository.lastCreatedTask?.isCompleted ?? true, "Новая задача должна быть не выполнена")
        
        XCTAssertTrue(mockPresenter.didCreateTaskCalled, "Presenter должен быть уведомлён об успехе")
        XCTAssertNotNil(mockPresenter.lastCreatedTask)
    }
    
    func testCreateTask_WithoutDescription() {
        // Arrange
        let title = "Task without description"
        
        // Act
        sut.createTask(title: title, description: nil)
        
        // Assert
        XCTAssertTrue(mockRepository.createCalled)
        XCTAssertEqual(mockRepository.lastCreatedTask?.title, title)
        XCTAssertNil(mockRepository.lastCreatedTask?.taskDescription, "Описание должно быть nil")
        
        XCTAssertTrue(mockPresenter.didCreateTaskCalled)
    }
    
    func testCreateTask_Failure() {
        // Arrange
        let expectedError = TestError(message: "Database error")
        mockRepository.errorToReturn = expectedError
        
        // Act
        sut.createTask(title: "Test", description: nil)
        
        // Assert
        XCTAssertTrue(mockRepository.createCalled)
        XCTAssertTrue(mockPresenter.didFailToCreateTaskCalled, "Presenter должен быть уведомлён об ошибке")
        XCTAssertNotNil(mockPresenter.lastCreateError)
    }
    
    func testCreateTask_GeneratesUniqueId() {
        // Act
        sut.createTask(title: "Task 1", description: nil)
        let firstTaskId = mockRepository.lastCreatedTask?.id
        
        Thread.sleep(forTimeInterval: 0.01)
        
        sut.createTask(title: "Task 2", description: nil)
        let secondTaskId = mockRepository.lastCreatedTask?.id
        
        // Assert
        XCTAssertNotNil(firstTaskId)
        XCTAssertNotNil(secondTaskId)
        XCTAssertNotEqual(firstTaskId, secondTaskId, "ID должны быть уникальными")
    }
    
    // MARK: - Tests: updateTask
    
    func testUpdateTask_Success() {
        // Arrange
        let originalTask = TaskEntity(
            id: 1,
            title: "Original Title",
            taskDescription: "Original Description",
            createdDate: Date(),
            isCompleted: false
        )
        
        let updatedTask = TaskEntity(
            id: 1,
            title: "Updated Title",
            taskDescription: "Updated Description",
            createdDate: originalTask.createdDate,
            isCompleted: true
        )
        
        // Act
        sut.updateTask(updatedTask)
        
        // Assert
        XCTAssertTrue(mockRepository.updateCalled, "Repository update должен быть вызван")
        XCTAssertEqual(mockRepository.lastUpdatedTask?.id, 1)
        XCTAssertEqual(mockRepository.lastUpdatedTask?.title, "Updated Title")
        XCTAssertEqual(mockRepository.lastUpdatedTask?.taskDescription, "Updated Description")
        XCTAssertTrue(mockRepository.lastUpdatedTask?.isCompleted ?? false)
        
        XCTAssertTrue(mockPresenter.didUpdateTaskCalled, "Presenter должен быть уведомлён об успехе")
        XCTAssertEqual(mockPresenter.lastUpdatedTask?.id, 1)
    }
    
    func testUpdateTask_Failure() {
        // Arrange
        let task = TaskEntity(
            id: 1,
            title: "Test",
            taskDescription: nil,
            createdDate: Date(),
            isCompleted: false
        )
        let expectedError = TestError(message: "Update failed")
        mockRepository.errorToReturn = expectedError
        
        // Act
        sut.updateTask(task)
        
        // Assert
        XCTAssertTrue(mockRepository.updateCalled)
        XCTAssertTrue(mockPresenter.didFailToUpdateTaskCalled, "Presenter должен быть уведомлён об ошибке")
        XCTAssertNotNil(mockPresenter.lastUpdateError)
    }
    
    func testUpdateTask_PreservesCreatedDate() {
        // Arrange
        let originalDate = Date(timeIntervalSince1970: 1000000)
        let task = TaskEntity(
            id: 1,
            title: "Updated Task",
            taskDescription: nil,
            createdDate: originalDate,
            isCompleted: true
        )
        
        // Act
        sut.updateTask(task)
        
        // Assert
        XCTAssertEqual(mockRepository.lastUpdatedTask?.createdDate, originalDate, "Дата создания должна сохраниться")
    }
}

// MARK: - Mock TaskEditInteractorOutput

class MockTaskEditInteractorOutput: TaskEditInteractorOutput {
    
    var didCreateTaskCalled = false
    var lastCreatedTask: TaskEntity?
    
    var didFailToCreateTaskCalled = false
    var lastCreateError: Error?
    
    var didUpdateTaskCalled = false
    var lastUpdatedTask: TaskEntity?
    
    var didFailToUpdateTaskCalled = false
    var lastUpdateError: Error?
    
    func didCreateTask(_ task: TaskEntity) {
        didCreateTaskCalled = true
        lastCreatedTask = task
    }
    
    func didFailToCreateTask(with error: Error) {
        didFailToCreateTaskCalled = true
        lastCreateError = error
    }
    
    func didUpdateTask(_ task: TaskEntity) {
        didUpdateTaskCalled = true
        lastUpdatedTask = task
    }
    
    func didFailToUpdateTask(with error: Error) {
        didFailToUpdateTaskCalled = true
        lastUpdateError = error
    }
}
