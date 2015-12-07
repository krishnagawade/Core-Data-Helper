//
//  NoteDetailViewController.swift
//  Notes-Swift
//
//  Created by Dion Larson on 11/13/14.
//  Copyright (c) 2014 MakeSchool. All rights reserved.
//

import UIKit
import CoreData

private let MARGIN_BUTTON : CGFloat = 100

class NoteDetailViewController: UIViewController {

    //class member

    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var previasBtnWidthContraints: NSLayoutConstraint!
    @IBOutlet weak var titleTextField: UITextField!

    var noteHandler : NoteHandler?
    
    //MARK: View lify cycle
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
    
        self.updateUI();
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            self.loadData()
            
            })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
            if !contentTextField.text.isEmpty
            {
                if noteHandler?.currentNote == nil
                {
                    noteHandler?.currentNote  = Note.insertNewObjectIntoContext(NSThread.currentThread().context())
                }
                
                noteHandler?.currentNote!.title = titleTextField.text;
                
                noteHandler?.currentNote!.detail = contentTextField.text
            }
        
        LocalStorage.saveThreadsContext()
    }
    
    
      //MARK: Functionality 
    
    func updateUI()
    {
        self.previasBtnWidthContraints.constant = (self.view.frame.width - MARGIN_BUTTON) / 4;
        
        if noteHandler?.currentNote != nil
        {
            titleTextField.text = noteHandler?.currentNote!.title
            contentTextField.text = noteHandler?.currentNote!.detail
        }
    }

    
    func loadData()->Void
    {
        let newItemNames = ["Apples", "Milk", "Bread", "Cheese", "Sausages", "Butter", "Orange Juice", "Cereal", "Coffee", "Eggs", "Tomatoes", "Fish"]
        
        // add families
        NSLog(" ======== Insert ======== ")
        
        for newItemName in newItemNames {
            let newItem: Note = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext:  NSThread.currentThread().context()) as! Note
            
            newItem.title = newItemName
            
            NSLog("Inserted New Family for \(newItemName) ")
        }
        
        LocalStorage.saveThreadsContext()
    }
    
}

