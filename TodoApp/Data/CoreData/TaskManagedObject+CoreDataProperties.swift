//
//  TaskManagedObject+CoreDataProperties.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 21.01.2026.
//
//

public import Foundation
public import CoreData


public typealias TaskManagedObjectCoreDataPropertiesSet = NSSet

extension TaskManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskManagedObject> {
        return NSFetchRequest<TaskManagedObject>(entityName: "Task")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String
    @NSManaged public var taskDescription: String?
    @NSManaged public var createdDate: Date
    @NSManaged public var isCompleted: Bool

}

extension TaskManagedObject : Identifiable {

}
