//
//  TaskRepository..swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import Foundation
import CoreData

final class TaskRepository: TaskRepositoryProtocol {
    
    // MARK: - Singleton
    
    static let shared = TaskRepository()
    
    // MARK: - Properties
    
    private let coreDataStack: CoreDataStack
    
    // MARK: - Initialization
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Fetch Operations
    
    func fetchAll(completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        let context = coreDataStack.viewContext
        let fetchRequest = TaskManagedObject.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createdDate", ascending: false)
        ]
        
        do {
            let managedObjects = try context.fetch(fetchRequest)
            let entities = managedObjects.map { $0.toEntity() }
            
            DispatchQueue.main.async {
                completion(.success(entities))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    func search(query: String, completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        let context = coreDataStack.viewContext
        let fetchRequest = TaskManagedObject.fetchRequest()
        
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            fetchAll(completion: completion)
            return
        }
        
        let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
        let descriptionPredicate = NSPredicate(format: "taskDescription CONTAINS[cd] %@", query)
        
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            titlePredicate,
            descriptionPredicate
        ])
        
        fetchRequest.predicate = compoundPredicate
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createdDate", ascending: false)
        ]
        
        do {
            let managedObjects = try context.fetch(fetchRequest)
            let entities = managedObjects.map { $0.toEntity() }
            
            DispatchQueue.main.async {
                completion(.success(entities))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Create Operation
    
    func create(task: TaskEntity, completion: @escaping (Result<TaskEntity, Error>) -> Void) {
        let context = coreDataStack.newBackgroundContext()
        
        context.perform {
            do {
                let managedObject = TaskManagedObject.create(from: task, in: context)
                try context.save()
                let savedEntity = managedObject.toEntity()
                
                DispatchQueue.main.async {
                    completion(.success(savedEntity))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Update Operation
    
    func update(task: TaskEntity, completion: @escaping (Result<TaskEntity, Error>) -> Void) {
        let context = coreDataStack.newBackgroundContext()
        
        context.perform {
            do {
                let fetchRequest = TaskManagedObject.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %lld", task.id)
                fetchRequest.fetchLimit = 1
                
                let results = try context.fetch(fetchRequest)
                
                guard let managedObject = results.first else {
                    let error = NSError(
                        domain: "TaskRepository",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "Task with id \(task.id) not found"]
                    )
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                managedObject.update(from: task)
                try context.save()
                let updatedEntity = managedObject.toEntity()
                
                DispatchQueue.main.async {
                    completion(.success(updatedEntity))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Delete Operation
    
    func delete(taskId: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
        let context = coreDataStack.newBackgroundContext()
        
        context.perform {
            do {
                let fetchRequest = TaskManagedObject.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %lld", taskId)
                fetchRequest.fetchLimit = 1
                
                let results = try context.fetch(fetchRequest)
                
                if let managedObject = results.first {
                    context.delete(managedObject)
                    try context.save()
                }
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Batch Operations
    
    func createBatch(tasks: [TaskEntity], completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        guard !tasks.isEmpty else {
            DispatchQueue.main.async {
                completion(.success([]))
            }
            return
        }
        
        let context = coreDataStack.newBackgroundContext()
        
        context.perform {
            do {
                var createdEntities: [TaskEntity] = []
                
                for task in tasks {
                    let managedObject = TaskManagedObject.create(from: task, in: context)
                    createdEntities.append(managedObject.toEntity())
                }
                
                try context.save()
                
                DispatchQueue.main.async {
                    completion(.success(createdEntities))
                }
            } catch {
                context.rollback()
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
