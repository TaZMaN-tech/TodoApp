//
//  TodoMapper.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import Foundation

final class TodoMapper {
    
    static func map(dtos: [TodoDTO]) -> [TaskEntity] {
        return dtos.map { dto in
            map(dto: dto)
        }
    }
    
    static func map(dto: TodoDTO) -> TaskEntity {
        return TaskEntity(
            id: Int64(dto.id),
            title: dto.todo,
            taskDescription: nil,
            createdDate: Date(),
            isCompleted: dto.completed
        )
    }
    
    static func map(response: TodoResponseDTO) -> [TaskEntity] {
        return map(dtos: response.todos)
    }
}
