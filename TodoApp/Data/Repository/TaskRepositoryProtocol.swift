//
//  TaskRepositoryProtocol.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 21.01.2026.
//

import Foundation

protocol TaskRepositoryProtocol {
    
    // MARK: - Fetch Operations
    
    func fetchAll(completion: @escaping (Result<[TaskEntity], Error>) -> Void)
    func search(query: String, completion: @escaping (Result<[TaskEntity], Error>) -> Void)
    
    // MARK: - Create Operation
    
    func create(task: TaskEntity, completion: @escaping (Result<TaskEntity, Error>) -> Void)
    
    // MARK: - Update Operation
    
    func update(task: TaskEntity, completion: @escaping (Result<TaskEntity, Error>) -> Void)
    
    // MARK: - Delete Operation
    
    func delete(taskId: Int64, completion: @escaping (Result<Void, Error>) -> Void)
    
    // MARK: - Batch Operations
    
    func createBatch(tasks: [TaskEntity], completion: @escaping (Result<[TaskEntity], Error>) -> Void)
}
