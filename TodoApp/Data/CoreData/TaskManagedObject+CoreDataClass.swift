//
//  TaskManagedObject+CoreDataClass.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 21.01.2026.
//
//

import Foundation
import CoreData

@objc(TaskManagedObject)
public class TaskManagedObject: NSManagedObject {
    
    /// Конвертирует TaskManagedObject в доменную модель TaskEntity
    /// - Returns: Доменная модель задачи
    func toEntity() -> TaskEntity {
        return TaskEntity(
            id: self.id,
            title: self.title,
            taskDescription: self.taskDescription,
            createdDate: self.createdDate,
            isCompleted: self.isCompleted
        )
    }
    
    /// Обновляет TaskManagedObject данными из доменной модели TaskEntity
    /// - Parameter entity: Доменная модель с обновлёнными данными
    func update(from entity: TaskEntity) {
        self.id = entity.id
        self.title = entity.title
        self.taskDescription = entity.taskDescription
        self.createdDate = entity.createdDate
        self.isCompleted = entity.isCompleted
    }
    
    /// Создаёт новый TaskManagedObject из доменной модели
    /// - Parameters:
    ///   - entity: Доменная модель задачи
    ///   - context: Контекст CoreData, в котором будет создан объект
    /// - Returns: Новый managed object
    static func create(from entity: TaskEntity, in context: NSManagedObjectContext) -> TaskManagedObject {
        let managedObject = TaskManagedObject(context: context)
        managedObject.update(from: entity)
        return managedObject
    }
}
