//
//  TaskEntity.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 21.01.2026.
//

import Foundation

struct TaskEntity {
    let id: Int64
    let title: String
    let taskDescription: String?
    let createdDate: Date
    let isCompleted: Bool
    
    init(
        id: Int64,
        title: String,
        taskDescription: String? = nil,
        createdDate: Date = Date(),
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.createdDate = createdDate
        self.isCompleted = isCompleted
    }
}

// MARK: - Equatable
extension TaskEntity: Equatable {
    static func == (lhs: TaskEntity, rhs: TaskEntity) -> Bool {
        return lhs.id == rhs.id
    }
}
