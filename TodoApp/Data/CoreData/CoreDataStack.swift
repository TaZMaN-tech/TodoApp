//
//  CoreDataStack.swift
//  TodoApp
//
//  Created by Тадевос Курдоглян on 21.01.2026.
//

import Foundation
import CoreData

final class CoreDataStack {
    
    // MARK: - Singleton
    
    static let shared = CoreDataStack()
    
    // MARK: - Properties
    
    private let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Initialization
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "TodoApp")
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error loading persistent store: \(error), \(error.userInfo)")
            }
            
            print("✅ CoreData persistent store loaded successfully")
            print("📁 Store location: \(storeDescription.url?.absoluteString ?? "unknown")")
        }
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Background Context
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }
    
    // MARK: - Save Context
    
    func saveViewContext() {
        let context = persistentContainer.viewContext
        
        guard context.hasChanges else {
            print("ℹ️ No changes to save in viewContext")
            return
        }
        
        do {
            try context.save()
            print("✅ ViewContext saved successfully")
        } catch {
            let nsError = error as NSError
            print("❌ Error saving viewContext: \(nsError), \(nsError.userInfo)")
        }
    }
    
    // MARK: - Convenience Methods
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { context in
            block(context)
            
            if context.hasChanges {
                do {
                    try context.save()
                    print("✅ Background context saved successfully")
                } catch {
                    let nsError = error as NSError
                    print("❌ Error saving background context: \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
}
