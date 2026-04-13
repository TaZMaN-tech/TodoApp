//
//  TaskEntity.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 21.01.2026.
//

import Foundation
import SwiftData

@Model
final class TaskItem {
    @Attribute(.unique) var id: Int64
    var title: String
    var taskDescription: String?
    var createdDate: Date
    var isCompleted: Bool
    
    init(
        id: Int64,
        title: String,
        taskDescription: String? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.createdDate = .now
        self.isCompleted = isCompleted
    }
}


// MARK: - Test Helpers (только для Preview и тестов)
extension TaskItem {
    static func mock(
        id: Int64 = 1,
        title: String = "Купить продукты",
        taskDescription: String? = "Молоко и хлеб",
        isCompleted: Bool = false
    ) -> TaskItem {
        TaskItem(id: id, title: title, taskDescription: taskDescription, isCompleted: isCompleted)
    }
}
