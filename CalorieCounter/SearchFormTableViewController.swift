//
//  SearchFormTableViewController.swift
//  CalorieCounter
//
//  Created by Oscar Vicente González Greco on 30/5/15.
//  Copyright (c) 2015 Oscarvgg. All rights reserved.
//

import UIKit

class SearchFormTableViewController: UITableViewController, UIPickerViewDelegate, UITextFieldDelegate {

    var textFieldBeingEdited: UITextField?
    
    var configuration: [String : NSDate] = [:]
    
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
        
        self.textFieldBeingEdited = textField
        
        let datePickerView = UIDatePicker(frame: CGRectZero)
        
        if textField.tag >= 1 && textField.tag <= 2 {
            
            datePickerView.datePickerMode = UIDatePickerMode.Date
        }
        else if textField.tag >= 3 && textField.tag <= 4 {
            
            datePickerView.datePickerMode = UIDatePickerMode.Time
        }
        
        datePickerView.addTarget(
            self,
            action: Selector("datePickerViewChanged:"),
            forControlEvents: UIControlEvents.ValueChanged)
        
        self.datePickerViewChanged(datePickerView)
        
        textField.inputView = datePickerView
        
        
        
        return true
    }
    
    
    func readValueFromTextField(editedField: UITextField) {
        
        var newDate: NSDate!
        
        let formatter = NSDateFormatter()
        
        
        if editedField.tag >= 1 && editedField.tag <= 2 {
            
            formatter.dateStyle = NSDateFormatterStyle.MediumStyle
            formatter.timeStyle = NSDateFormatterStyle.NoStyle
            
            if let date = formatter.dateFromString(editedField.text) {
                
                newDate = date
                
                if editedField.tag == 1 {
                    
                    configuration["fromDate"] = newDate
                }
                else if editedField.tag == 2 {
                    
                    configuration["toDate"] = newDate
                }
            }
        }
        else if editedField.tag >= 3 && editedField.tag <= 4 {
            
            formatter.dateStyle = NSDateFormatterStyle.NoStyle
            formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            
            if let date = formatter.dateFromString(editedField.text) {
                
                newDate = date
                
                if editedField.tag == 3 {
                    
                    configuration["fromTime"] = newDate
                }
                else if editedField.tag == 4 {
                    
                    configuration["toTime"] = newDate
                }
            }
        }
        
        
    }
    
    
    // MARK: - Picker view delegate
    
    func datePickerViewChanged(sender: UIDatePicker) {
        
        var formatedDate: String = ""
        
        if self.textFieldBeingEdited?.tag >= 1 && self.textFieldBeingEdited?.tag <= 2 {
            
            formatedDate = NSDateFormatter.localizedStringFromDate(
                sender.date,
                dateStyle: NSDateFormatterStyle.MediumStyle,
                timeStyle: NSDateFormatterStyle.NoStyle)
        }
        else if self.textFieldBeingEdited?.tag >= 3 && self.textFieldBeingEdited?.tag <= 4 {
            
            formatedDate = NSDateFormatter.localizedStringFromDate(
                sender.date,
                dateStyle: NSDateFormatterStyle.NoStyle,
                timeStyle: NSDateFormatterStyle.ShortStyle)
        }
        
        self.textFieldBeingEdited?.text = formatedDate
    }
    

    // MARK: - Table view delegate
    
    @IBAction func didTapCancel(sender: UIButton) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - Actions
    
    
    func validateFields() -> Bool {
        
        let alert: UIAlertController!
        
        let action = UIAlertAction(
            title: "Ok",
            style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
                
        }
        
        if self.configuration["fromDate"] == nil || self.configuration["toDate"] == nil {
            
            alert = UIAlertController(
                title: "Invalid field",
                message: "From and to dates are required",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(action)
            
            self.presentViewController(
                alert,
                animated: true,
                completion: { () -> Void in
            })
            
            return false
        }
        
        
        if (self.configuration["fromTime"] != nil && self.configuration["toTime"] == nil) ||
            (self.configuration["fromTime"] == nil && self.configuration["toTime"] != nil) {
                
                alert = UIAlertController(
                    title: "Invalid field",
                    message: "\"From\" time and \"To\" time must be both set or both empty",
                    preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(action)
                
                self.presentViewController(
                    alert,
                    animated: true,
                    completion: { () -> Void in
                })
                
                return false
        }
        
        if let fromTime = self.configuration["fromTime"], toTime = self.configuration["toTime"] {
        
            if fromTime.compare(toTime) == NSComparisonResult.OrderedDescending {
                
                alert = UIAlertController(
                    title: "Invalid field",
                    message: "\"To\" time must be gratter than \"From\" time",
                    preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(action)
                
                self.presentViewController(
                    alert,
                    animated: true,
                    completion: { () -> Void in
                })
                
                return false
            }
        }
        
        return true
    }
    
    
    @IBAction func didTapSearch(sender: UIButton) {
        
        // Stop editing on each text field
        for index in 1...self.tableView.numberOfRowsInSection(0) {
            
            let i = index - 1
            
            // get the text field for the cell at i
            let textField = self.tableView.cellForRowAtIndexPath(
                NSIndexPath(forRow: i, inSection: 0))?
                .viewWithTag(index) as? UITextField
            
            if let textField = textField {
                
                self.readValueFromTextField(textField)
            
                textField.resignFirstResponder()
            }
        }
        
        self.textFieldBeingEdited = nil
        
        if self.validateFields() {
            
            self.performSegueWithIdentifier("searchResultsSegue", sender: nil)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let resultsViewController = segue.destinationViewController as? SearchResultsTableViewController {
            
            resultsViewController.configuration = self.configuration
        }
        
    }
}
