//
//  ManagedObjectContext.swift
//  Notes-Swift
//
//  Created by Krishna Gawade on 17/11/15.
//  Copyright (c) 2015 MakeSchool. All rights reserved.
//

import UIKit
import CoreData

class ManagedObjectContext: NSManagedObjectContext {
    
    func addNotification()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onNotification:", name: NSManagedObjectContextDidSaveNotification, object: nil)
    }
    
    func onNotification(notification: NSNotification)
    {
        if notification.object as? NSManagedObjectContext != self
        {
            if notification.object?.persistentStoreCoordinator == self.persistentStoreCoordinator
            {
                self.mergeChangesFromContextDidSaveNotification(notification)
            }
        }
    }
    
    func removeNotification()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    deinit
    {
        print("\(name) is being deinitialized")
        removeNotification()
    }
}
