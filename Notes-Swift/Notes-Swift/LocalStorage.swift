//
//  LocalStorage.swift
//  Notes-Swift
//
//  Created by Krishna Gawade on 16/11/15.
//  Copyright (c) 2015 MakeSchool. All rights reserved.
//

import UIKit
import CoreData

class LocalStorage : NSObject
{
    let recursiveLock = NSRecursiveLock()
    
    //MARK: - Initialization
    
    class var sharedInstance: LocalStorage
    {
        struct Static
        {
            static var onceToken: dispatch_once_t = 0
            static var instance: LocalStorage? = nil
        }
        
        dispatch_once(&Static.onceToken)
            {
                Static.instance = LocalStorage.init()
                Static.instance?.persistentStoreCoordinator
                Static.instance?.recursiveLock
        }
    
        return Static.instance!
    }
    
    override init()
    {
        print("LocalStorage initialize", terminator: "");
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.makeschool.Notes-Swift" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Notes-Swift", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Notes-Swift.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as AnyObject as? [NSObject : AnyObject])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
// MARK: - Core Data Saving support
    
    class func saveThreadsContext() {
        saveContextOfThread(NSThread.currentThread())
    }
    
    class func saveContextOfThread(thread: NSThread) {
        saveContext(thread.context())
    }
    
    class func saveContext(context: NSManagedObjectContext) {
        
        LocalStorage.sharedInstance.recursiveLock.lock()
        
            var error: NSError? = nil
           
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        
        print(error)
     
        LocalStorage.sharedInstance.recursiveLock.unlock()
    }
    
    // MARK: - Core Data Fetch Data
    
    class func executeFetchRequest(request: NSFetchRequest) -> [AnyObject]?
    {
        return LocalStorage.executeFetchRequestOnThread(request, thread: NSThread.currentThread())
    }
    
    class func executeFetchRequestOnThread(request: NSFetchRequest, thread : NSThread) -> [AnyObject]?
    {
        return LocalStorage.executeFetchRequestInContext(request, context: thread.context())
    }
    
    class func executeFetchRequestInContext(request: NSFetchRequest, context:NSManagedObjectContext?) -> [AnyObject]?
    {
        LocalStorage.sharedInstance.recursiveLock.lock()
        
        var error: NSError? = nil
        
        var result : [AnyObject]? = nil
        
        if(context != nil)
        {
            do {
                result = try context?.executeFetchRequest(request)
            } catch let error1 as NSError {
                error = error1
                result = nil
            }
        }
        
        LocalStorage.sharedInstance.recursiveLock.unlock()
        
        return result
    }
    
    class func existingManagedObjectForObjectID(objectId : NSManagedObjectID) -> NSManagedObject
    {
        LocalStorage.sharedInstance.recursiveLock.lock()
        
        var error: NSError? = nil
        
        var object : NSManagedObject?
        do {
            object = try NSThread.currentThread().context().existingObjectWithID(objectId)
        } catch let error1 as NSError {
            error = error1
            object = nil
        }
        
        LocalStorage.sharedInstance.recursiveLock.unlock()
        
        return object!
    }
}
