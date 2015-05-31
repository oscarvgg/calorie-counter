//
//  SettingsTableViewController.swift
//  CalorieCounter
//
//  Created by Oscar Vicente González Greco on 30/5/15.
//  Copyright (c) 2015 Oscarvgg. All rights reserved.
//

import RealmSwift

import UIKit

class SettingsTableViewController: UITableViewController {
    
    var auxiliarUser: User!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.createAuxilliarUser()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func createAuxilliarUser() {
        
        let localUser = User.currentUser()!
        self.auxiliarUser = User()
        
        self.auxiliarUser.objectId = localUser.objectId
        self.auxiliarUser.username = localUser.username
        self.auxiliarUser.email = localUser.email
        self.auxiliarUser.maxDailyCalorieCount = localUser.maxDailyCalorieCount
        self.auxiliarUser.calories.extend(localUser.calories)
        self.auxiliarUser.createdAt = localUser.createdAt
        self.auxiliarUser.updatedAt = localUser.updatedAt
    }

    
    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if let textField = cell.viewWithTag(1) as? UITextField {
            
            switch (indexPath.row) {
                
            case 0:
                textField.text = String(self.auxiliarUser.maxDailyCalorieCount)
                
            default:
                break
            }
        }
    }
    
    
    // MARK: - Text field delegate
    
    func readValueFromTextField(editedField: UITextField) {
        
        if let cell = editedField.superview?.superview as? UITableViewCell {
            
            if let row = self.tableView.indexPathForCell(cell)?.row {
                
                switch row {
                    
                case 0:
                    
                    self.auxiliarUser.maxDailyCalorieCount = editedField.text.toInt()!
                    
                default:
                    break
                }
            }
        }
        
    }
    
    
    // MARK: - Validate
    
    func validateFields() -> Bool {
        
        let alert: UIAlertController!
        
        let action = UIAlertAction(
            title: "Ok",
            style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
                
        }
        
        if self.auxiliarUser.maxDailyCalorieCount <= 0 {
            
            alert = UIAlertController(
                title: "Invalid field",
                message: "Enter a value higher than zero",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(action)
            
            self.presentViewController(
                alert,
                animated: true,
                completion: { () -> Void in
            })
            
            return false
        }
        
        return true
    }
    
    
    // MARK: - Actions
    
    @IBAction func didTapSave(sender: UIButton) {
        
        // Stop editing on each text field
        for index in 1...self.tableView.numberOfRowsInSection(0) {
            
            let i = index - 1
            
            // get the text field for the cell at i
            let textField = self.tableView.cellForRowAtIndexPath(
                NSIndexPath(forRow: i, inSection: 0))?
                .viewWithTag(1) as? UITextField
            
            self.readValueFromTextField(textField!)
            
            textField?.resignFirstResponder()
        }
        
        if !validateFields() {
            
            return
        }
        
        // save to server
        self.auxiliarUser.save(Calorie.self, completion: { (succeeded:Bool, error: NSError?) -> Void in
            
            self.createAuxilliarUser()
            
            NSNotificationCenter.defaultCenter().postNotificationName(
                Constants.Notifications.Storage.maxDailyCaloriesUpdated,
                object: self.auxiliarUser.maxDailyCalorieCount)
            
            let alert = UIAlertController(
                title: error == nil ? "Done" : "Oops...",
                message: error == nil ?  "The changes were saved" : "An error ocurred while saving your changes",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            let action = UIAlertAction(
                title: "Ok",
                style: UIAlertActionStyle.Default,
                handler: { (actions: UIAlertAction!) -> Void in
                    
            })
            
            alert.addAction(action)
            
            self.presentViewController(
                alert,
                animated: true,
                completion: { () -> Void in
                    
            })
        })
    }
    

    @IBAction func didTapLogOut(sender: UIButton) {
        
        User.logOutCurrentUser()
        
        let mainLoginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LogInTableViewController") as! LogInTableViewController
        
        self.navigationController?.viewControllers = [mainLoginViewController]
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
}
