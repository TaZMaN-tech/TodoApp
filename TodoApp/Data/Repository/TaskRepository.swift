//
//  TaskRepository.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import Foundation
import SwiftData

@MainActor
final class TaskRepository: TaskRepositoryProtocol {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Fetch Operations
    
    func fetchAll() async throws -> [TaskItem] {
        // FetchDescriptor = NSFetchRequest, но типобезопасный
        let descriptor = FetchDescriptor<TaskItem>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func search(query: String) async throws -> [TaskItem] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return try await fetchAll()
        }
        // #Predicate — типобезопасный, компилятор проверяет поля
        // Старый вариант: NSPredicate(format: "title CONTAINS[cd] %@", query) — строка, нет проверки
        let descriptor = FetchDescriptor<TaskItem>(
            predicate: #Predicate { item in
                item.title.localizedStandardContains(query) ||
                (item.taskDescription ?? "").localizedStandardContains(query)
            }
        )
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Create Operation
    
    func create(task: TaskItem) async throws -> TaskItem {
        modelContext.insert(task)    // insert вместо create(in:)
        try modelContext.save()
        return task
    }
    
    
    // MARK: - Update Operation
    
    func update(task: TaskItem) async throws -> TaskItem {
        // SwiftData: изменения на @Model объекте отслеживаются автоматически
        // Просто меняй свойства — save() зафиксирует
        try modelContext.save()
        return task
    }
    
    
    // MARK: - Delete Operation
    
    func delete(taskId: Int64) async throws {
        let descriptor = FetchDescriptor<TaskItem>(
            predicate: #Predicate { $0.id == taskId }
        )
        if let item = try modelContext.fetch(descriptor).first {
            modelContext.delete(item)
            try modelContext.save()
        }
    }
    
    // MARK: - Batch Operations
    
    func createBatch(tasks: [TaskItem]) async throws -> [TaskItem] {
        tasks.forEach { modelContext.insert($0) }
        try modelContext.save()
        return tasks
    }
}
