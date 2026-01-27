//
//  TaskRepository.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 23.01.2026.
//

import Foundation
import CoreData
import os

final class TaskRepository: TaskRepositoryProtocol {

    // MARK: - Singleton

    static let shared = TaskRepository()

    // MARK: - Properties

    private let coreDataStack: CoreDataStack
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "TodoApp",
        category: "TaskRepository"
    )

    // MARK: - Initialization

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - Fetch Operations

    func fetchAll(completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        let context = coreDataStack.viewContext

        context.perform { [weak self] in
            guard let self else { return }

            let request = TaskManagedObject.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]

            do {
                let objects = try context.fetch(request)
                let entities = objects.map { $0.toEntity() }
                self.finish(completion, with: .success(entities))
            } catch {
                self.logger.error("fetchAll failed: \(error.localizedDescription)")
                self.finish(completion, with: .failure(error))
            }
        }
    }

    func search(query: String, completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            fetchAll(completion: completion)
            return
        }

        let context = coreDataStack.viewContext

        context.perform { [weak self] in
            guard let self else { return }

            let request = TaskManagedObject.fetchRequest()

            let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", trimmed)
            let descriptionPredicate = NSPredicate(format: "taskDescription CONTAINS[cd] %@", trimmed)
            request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, descriptionPredicate])

            request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]

            do {
                let objects = try context.fetch(request)
                let entities = objects.map { $0.toEntity() }
                self.finish(completion, with: .success(entities))
            } catch {
                self.logger.error("search failed: \(error.localizedDescription)")
                self.finish(completion, with: .failure(error))
            }
        }
    }

    // MARK: - Create Operation

    func create(task: TaskEntity, completion: @escaping (Result<TaskEntity, Error>) -> Void) {
        let context = coreDataStack.newBackgroundContext()

        context.perform { [weak self] in
            guard let self else { return }

            do {
                let object = TaskManagedObject.create(from: task, in: context)
                try context.save()
                self.finish(completion, with: .success(object.toEntity()))
            } catch {
                context.rollback()
                self.logger.error("create failed: \(error.localizedDescription)")
                self.finish(completion, with: .failure(error))
            }
        }
    }

    // MARK: - Update Operation

    func update(task: TaskEntity, completion: @escaping (Result<TaskEntity, Error>) -> Void) {
        let context = coreDataStack.newBackgroundContext()

        context.perform { [weak self] in
            guard let self else { return }

            do {
                let request = TaskManagedObject.fetchRequest()
                request.predicate = NSPredicate(format: "id == %lld", task.id)
                request.fetchLimit = 1

                guard let object = try context.fetch(request).first else {
                    self.finish(completion, with: .failure(Self.notFoundError(id: task.id)))
                    return
                }

                object.update(from: task)
                try context.save()

                self.finish(completion, with: .success(object.toEntity()))
            } catch {
                context.rollback()
                self.logger.error("update failed: \(error.localizedDescription)")
                self.finish(completion, with: .failure(error))
            }
        }
    }

    // MARK: - Delete Operation

    func delete(taskId: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
        let context = coreDataStack.newBackgroundContext()

        context.perform { [weak self] in
            guard let self else { return }

            do {
                let request = TaskManagedObject.fetchRequest()
                request.predicate = NSPredicate(format: "id == %lld", taskId)
                request.fetchLimit = 1

                if let object = try context.fetch(request).first {
                    context.delete(object)
                    try context.save()
                }

                self.finish(completion, with: .success(()))
            } catch {
                context.rollback()
                self.logger.error("delete failed: \(error.localizedDescription)")
                self.finish(completion, with: .failure(error))
            }
        }
    }

    // MARK: - Batch Operations

    func createBatch(tasks: [TaskEntity], completion: @escaping (Result<[TaskEntity], Error>) -> Void) {
        guard !tasks.isEmpty else {
            finish(completion, with: .success([]))
            return
        }

        let context = coreDataStack.newBackgroundContext()

        context.perform { [weak self] in
            guard let self else { return }

            do {
                let created: [TaskEntity] = tasks.map { task in
                    let object = TaskManagedObject.create(from: task, in: context)
                    return object.toEntity()
                }

                try context.save()
                self.finish(completion, with: .success(created))
            } catch {
                context.rollback()
                self.logger.error("createBatch failed: \(error.localizedDescription)")
                self.finish(completion, with: .failure(error))
            }
        }
    }

    // MARK: - Helpers

    private func finish<T>(
        _ completion: @escaping (Result<T, Error>) -> Void,
        with result: Result<T, Error>
    ) {
        if Thread.isMainThread {
            completion(result)
        } else {
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    private static func notFoundError(id: Int64) -> NSError {
        NSError(
            domain: "TaskRepository",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "Task with id \(id) not found"]
        )
    }
}
