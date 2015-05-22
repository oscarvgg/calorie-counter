//
//  NewEntryTableViewController.swift
//  CalorieCounter
//
//  Created by Oscar Vicente González Greco on 22/5/15.
//  Copyright (c) 2015 Oscarvgg. All rights reserved.
//

import UIKit

import RealmSwift

class NewEntryTableViewController: UITableViewController, UIPickerViewDelegate, UITextFieldDelegate {

    var newEntry = Calorie()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Text field delegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        let dateTextField = self.tableView
            .cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))?
            .viewWithTag(1) as! UITextField
        
        if textField == dateTextField {
            
            let datePickerView = UIDatePicker(frame: CGRectZero)
            datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
            
            datePickerView.addTarget(
                self,
                action: Selector("datePickerViewChanged:"),
                forControlEvents: UIControlEvents.ValueChanged)
            
            self.datePickerViewChanged(datePickerView)
            
            textField.inputView = datePickerView
        }
        
        return true
    }
    
    
    func textFieldDidEndEditing(editedField: UITextField) {
        
        if let cell = editedField.superview?.superview as? UITableViewCell {
            
            if let row = self.tableView.indexPathForCell(cell)?.row {
                
                switch row {
                    
                case 0:
                    
                    self.newEntry.text = editedField.text
                    
                case 1:
                    
                    if let intValue = editedField.text.toInt() {
                        
                        self.newEntry.value = intValue
                    }
                    
                case 2:
                    
                    let formatter = NSDateFormatter()
                    formatter.dateStyle = NSDateFormatterStyle.MediumStyle
                    formatter.timeStyle = NSDateFormatterStyle.ShortStyle
                    
                    if let date = formatter.dateFromString(editedField.text) {
                        
                        self.newEntry.eatenOn = date
                    }
                    
                default:
                    break
                }
            }
        }
        
    }
    
    // MARK: - Picker view delegate
    
    func datePickerViewChanged(sender: UIDatePicker) {
        
        let formatedDate = NSDateFormatter.localizedStringFromDate(
            sender.date,
            dateStyle: NSDateFormatterStyle.MediumStyle,
            timeStyle: NSDateFormatterStyle.ShortStyle)
        
        let dateTextField = self.tableView
            .cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))?
            .viewWithTag(1) as! UITextField
        
        dateTextField.text = formatedDate
    }

    @IBAction func didTapCancel(sender: UIButton) {
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            
        })
    }
    
    
    @IBAction func didTapSave(sender: UIButton) {
        
        // Stop editing on each text field
        for index in 1...self.tableView.numberOfRowsInSection(0) {
            
            let i = index - 1
            
            // get the text field for the cell at i
            let textField = self.tableView.cellForRowAtIndexPath(
                NSIndexPath(forRow: i, inSection: 0))?
                .viewWithTag(1) as? UITextField
            
            textField?.resignFirstResponder()
        }
        
        let user = User.currentUser()
        
        if let user = user {
            
            self.newEntry.remoteOwner = user
        
            self.newEntry.save(Calorie.self, completion: { (savedEntry: Calorie?, error: NSError?) -> Void in
                
                self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })
            })
        }
    }
    
}
