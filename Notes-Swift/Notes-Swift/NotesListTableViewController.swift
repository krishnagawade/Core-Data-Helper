//
//  NotesListTableViewController.swift
//  Notes-Swift
//
//  Created by Dion Larson on 11/13/14.
//  Copyright (c) 2014 MakeSchool. All rights reserved.
//

import UIKit
import CoreData

class NotesListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate
{
    //MARK: - Class member
    
    @IBOutlet weak var addBtn: UIBarButtonItem!
    var isChangeNote : Bool! = false
    
    
    //MARK: View lify cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBtn?.target = self
        addBtn?.action = "addNote"
        
        var error: NSError? = nil
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAsppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return fetchedResultsController.fetchedObjects!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotesCell", forIndexPath: indexPath)
        
        self.configureCellAtIndexPath(cell, indexPath: indexPath)
        
        return cell
    }
    
    func configureCellAtIndexPath(cell: UITableViewCell, indexPath: NSIndexPath)
    {
        let note : Note! =  fetchedResultsController.fetchedObjects![indexPath.row] as! Note
        
        if note.title?.isEmpty != nil
        {
            cell.textLabel?.text = note.title;
        }
        else
        {
            cell.textLabel?.text = note.detail;
        }
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.Delete
        {
            if let note = self.fetchedResultsController.fetchedObjects![indexPath.row] as? Note
            {
                NSThread.currentThread().context().deleteObject(note)
                
                LocalStorage.saveThreadsContext()
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(VC_CONSTANT.VC_NoteDetailViewController, sender:  fetchedResultsController.fetchedObjects![indexPath.row])
    }
    
    //MARK: FetchController
    
    lazy var fetchedResultsController: NSFetchedResultsController =
    {
        let frc = NSFetchedResultsController(
            fetchRequest: Note.fetchRequest(),
            managedObjectContext: NSThread.currentThread().context(),
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    //MARK: FetchController delegate
    
    /* Notifies the delegate that section and object changes are about to be processed and notifications will be sent.  Enables NSFetchedResultsController change tracking.
    Clients utilizing a UITableView may prepare for a batch of updates by responding to this method with -beginUpdates
    */
    
    func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        self.tableView.beginUpdates()
    }
    
    /* Notifies the delegate that a fetched object has been changed due to an add, remove, move, or update. Enables NSFetchedResultsController change tracking.
    controller - controller instance that noticed the change on its fetched objects
    anObject - changed object
    indexPath - indexPath of changed object (nil for inserts)
    type - indicates if the change was an insert, delete, move, or update
    newIndexPath - the destination path for inserted or moved objects, nil otherwise
    
    Changes are reported with the following heuristics:
    
    On Adds and Removes, only the Added/Removed object is reported. It's assumed that all objects that come after the affected object are also moved, but these moves are not reported.
    The Move object is reported when the changed attribute on the object is one of the sort descriptors used in the fetch request.  An update of the object is assumed in this case, but no separate update message is sent to the delegate.
    The Update object is reported when an object's state changes, and the changed attributes aren't part of the sort keys.
    */
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
        switch(type)
        {
            
        case NSFetchedResultsChangeType.Insert:
            
            if let insertIndexPath = newIndexPath
            {
                isChangeNote = true
                
                self.tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Right)
            }
            
        case NSFetchedResultsChangeType.Delete:
            
            if let insertIndexPath = indexPath
            {
                self.tableView.deleteRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            
        case NSFetchedResultsChangeType.Update:
            
            self.configureCellAtIndexPath(self.tableView(tableView, cellForRowAtIndexPath: indexPath!), indexPath: indexPath!)
            
        default:
            print("");
        }
    }
    
    /* Notifies the delegate that all section and object changes have been sent. Enables NSFetchedResultsController change tracking.
    Providing an empty implementation will enable change tracking if you do not care about the individual callbacks.
    */
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        self.tableView.endUpdates()
        
        if !isChangeNote
        {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == VC_CONSTANT.VC_NoteDetailViewController
        {
            let vc : NoteDetailViewController = segue.destinationViewController as! NoteDetailViewController
            
            vc.noteHandler = NoteHandler()
            
            vc.noteHandler!.notes = self.fetchedResultsController.fetchedObjects
            
            vc.noteHandler!.currentNote = sender as? Note
            
            if sender != nil
            {
                let notes : NSArray = self.fetchedResultsController.fetchedObjects!
                
                vc.noteHandler?.currentIndex = notes.indexOfObject(sender!)
            }
        }
    }
    
    //MARK: - Other Functionality
    
    func addNote()
    {
        self.performSegueWithIdentifier(VC_CONSTANT.VC_NoteDetailViewController, sender: nil)
    }
}
