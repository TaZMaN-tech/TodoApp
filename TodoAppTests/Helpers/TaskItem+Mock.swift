//
//  TaskItem+Mock.swift
//  TodoAppTests
//
//  Created by Тадевос Курдоглян on 13.04.2026.
//

import Foundation
@testable import TodoApp

extension TaskItem {
    // Фабрика для тестов — все параметры опциональны
    // Позволяет писать: TaskItem.mock() или TaskItem.mock(title: "Test")
    static func mock(
        id: Int64 = 1,
        title: String = "Тестовая задача",
        taskDescription: String? = nil,
        isCompleted: Bool = false
    ) -> TaskItem {
        TaskItem(
            id: id,
            title: title,
            taskDescription: taskDescription,
            isCompleted: isCompleted
        )
    }

    static func mocks(count: Int) -> [TaskItem] {
        (0..<count).map {
            mock(id: Int64($0), title: "Задача \($0)")
        }
    }
}
