//
//  NSThread+Context.swift
//  Notes-Swift
//
//  Created by Krishna Gawade on 16/11/15.
//  Copyright (c) 2015 MakeSchool. All rights reserved.
//

import Foundation
import CoreData
import ObjectiveC

private let _helperClassKey = malloc(4)

extension NSThread
{
    func context() -> NSManagedObjectContext
    {
        var context = objc_getAssociatedObject(self, _helperClassKey) as? NSManagedObjectContext
        
        if context == nil
        {
            objc_setAssociatedObject(self, _helperClassKey, ManagedObjectContext(), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            context = objc_getAssociatedObject(self, _helperClassKey) as? NSManagedObjectContext
            let localStorage : LocalStorage! = LocalStorage.sharedInstance
            context!.persistentStoreCoordinator = localStorage.persistentStoreCoordinator
            context!.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            (context as! ManagedObjectContext).addNotification()
        }
       
        return context!
    }
}