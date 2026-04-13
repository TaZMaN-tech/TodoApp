//
//  TodoMapper.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import Foundation

final class TodoMapper {
    
    static func map(dtos: [TodoDTO]) -> [TaskItem] {
        return dtos.map { dto in
            map(dto: dto)
        }
    }
    
    static func map(dto: TodoDTO) -> TaskItem {
        return TaskItem(
            id: Int64(dto.id),
            title: dto.todo,
            taskDescription: nil,
            isCompleted: dto.completed
        )
    }
    
    static func map(response: TodoResponseDTO) -> [TaskItem] {
        return map(dtos: response.todos)
    }
}
