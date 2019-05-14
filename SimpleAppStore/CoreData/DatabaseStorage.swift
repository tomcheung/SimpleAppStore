//
//  DatabaseStorage.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 13/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import Foundation
import CoreData
import ReactiveSwift

class DatabaseStorage {
    
    enum AppType: Int {
        case appListing = 0
        case appRecommendation = 1
        
    }
    
    static let shared = DatabaseStorage()
    
    private init() {
        
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "AppDatabaseModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    private func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private lazy var backgroundContext = self.persistentContainer.newBackgroundContext()
    var viewContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    
    // MARK: - Public function
    func clearAllRecords(inBackground: Bool) throws {
        let context = inBackground ? self.backgroundContext : self.viewContext
        let fetchAppListingRequest: NSFetchRequest<AppEntity> = AppEntity.fetchRequest()
        let items = try context.fetch(fetchAppListingRequest)
        for item in items {
            context.delete(item)
        }
    }
    
    func fetchData(type: AppType, inBackground: Bool) throws -> [AppEntity] {
        let context = inBackground ? self.backgroundContext : self.viewContext
        let fetchAppListingRequest: NSFetchRequest<AppEntity> = AppEntity.fetchRequest()
        fetchAppListingRequest.predicate = NSPredicate(format: "type == %i", type.rawValue)
        fetchAppListingRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        return try context.fetch(fetchAppListingRequest)
    }
    
    func saveData(appList: [App], type: AppType, clearPreviousRecords: Bool, inBackground: Bool, offset: Int) throws {
        let context = inBackground ? self.backgroundContext : self.viewContext
        
        if clearPreviousRecords {
            let items = try self.fetchData(type: type, inBackground: inBackground)
            for item in items {
                context.delete(item)
            }
            
            print("Remove \(items.count) old \(type) records")
        }
        
        for (index, app) in appList.enumerated() {
            let appEntity = AppEntity(context: context)
            appEntity.updateValue(from: app)
            appEntity.type = NSNumber(value: type.rawValue)
            appEntity.order = Int32(offset + index)
            context.insert(appEntity)
        }
        
        if inBackground {
            try self.backgroundContext.save()
        } else {
            self.saveContext()
        }
        print("\(appList.count) \(type) records inserted")
    }

}
