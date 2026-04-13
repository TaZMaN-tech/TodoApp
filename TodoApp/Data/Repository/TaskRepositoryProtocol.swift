//
//  TaskRepositoryProtocol.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 21.01.2026.
//

import Foundation

@MainActor
protocol TaskRepositoryProtocol {
    
    // MARK: - Fetch Operations
    
    func fetchAll() async throws -> [TaskItem]
    func search(query: String) async throws -> [TaskItem]
    
    // MARK: - Create Operation
    
    func create(task: TaskItem) async throws -> TaskItem
    
    // MARK: - Update Operation
    
    @discardableResult
    func update(task: TaskItem) async throws -> TaskItem
    
    // MARK: - Delete Operation
    
    func delete(taskId: Int64) async throws
    
    // MARK: - Batch Operations
    
    func createBatch(tasks: [TaskItem]) async throws -> [TaskItem]
}
