//
//  Note.swift
//  Notes-Swift
//
//  Created by Krishna Gawade on 17/11/15.
//  Copyright (c) 2015 MakeSchool. All rights reserved.
//

import UIKit
import CoreData

@objc(Note)

class Note: NSManagedObject
{
    @NSManaged var title: String?
    @NSManaged var detail: String?
    @NSManaged var date: NSDate?
    
    override func awakeFromInsert()
    {
        self.date = NSDate()
    }
    
    class func entityName() -> NSString
    {
        return "Note"
    }
    
    class func insertNewObjectIntoContext(context : NSManagedObjectContext) -> Note
    {
        let note = NSEntityDescription.insertNewObjectForEntityForName(self.entityName() as String, inManagedObjectContext:context) as! Note;
       
        return note
    }
    
    class func fetchRequest() -> NSFetchRequest
    {
        let request: NSFetchRequest = NSFetchRequest(entityName: "Note")
        
        let sorter: NSSortDescriptor = NSSortDescriptor(key: "title" , ascending: true)
     
        request.sortDescriptors = [sorter]
        
        request.returnsObjectsAsFaults = false
        
        return request
    }
}
