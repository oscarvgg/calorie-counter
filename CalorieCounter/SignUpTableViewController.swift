//
//  SignUpTableViewController.swift
//  CalorieCounter
//
//  Created by Oscar Vicente González Greco on 18/5/15.
//  Copyright (c) 2015 Oscarvgg. All rights reserved.
//

import UIKit

class SignUpTableViewController: UITableViewController {

    
    var loggedUser: User?
    
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "mainViewSegue" {
            
            let mainViewController =
            segue.destinationViewController as! MainTableViewController
            
            mainViewController.localUser = self.loggedUser
        }
    }
    
    
    // MARK: - Validation
    
    func isEmailValid() -> Bool {
        
        let textField = self.tableView.cellForRowAtIndexPath(
            NSIndexPath(forRow: 1, inSection: 0))?
            .viewWithTag(1) as! UITextField
        
        let candidate = textField.text
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
    
    
    func isFieldEmpty(candidate: String) -> Bool {
        
        if candidate.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) <= 0 {
            return false
        }
        
        return true
    }
    
    
    func isUsernameValid() -> Bool {
        
        let textField = self.tableView.cellForRowAtIndexPath(
            NSIndexPath(forRow: 0, inSection: 0))?
            .viewWithTag(1) as! UITextField
        
        return self.isFieldEmpty(textField.text)
    }
    
    
    func isPasswordValid() -> Bool {
        
        let textField = self.tableView.cellForRowAtIndexPath(
            NSIndexPath(forRow: 2, inSection: 0))?
            .viewWithTag(1) as! UITextField
        
        return self.isFieldEmpty(textField.text)
    }
    
    
    func validateFields() -> Bool {
        
        let alert: UIAlertController!
        
        let action = UIAlertAction(
            title: "Ok",
            style: UIAlertActionStyle.Default) { (action: UIAlertAction!) -> Void in
                
        }
        
        
        if !self.isUsernameValid() {
            
            alert = UIAlertController(
                title: "Invalid field",
                message: "Username can't be empty",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(action)
            
            self.presentViewController(
                alert,
                animated: true,
                completion: { () -> Void in
            })
            
            return false
        }
        
        
        if !self.isEmailValid() {
            
            alert = UIAlertController(
                title: "Invalid field",
                message: "Email field is not valid",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(action)
            
            self.presentViewController(
                alert,
                animated: true,
                completion: { () -> Void in
            })
            
            return false
        }
        
        
        if !self.isPasswordValid() {
            
            alert = UIAlertController(
                title: "Invalid field",
                message: "Password can't be empty",
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
    
    @IBAction func didTapSignUp(sender: UIButton) {
        
        // Stop editing on each text field
        for index in 1...self.tableView.numberOfRowsInSection(0) {
            
            let i = index - 1
            
            // get the text field for the cell at i
            let textField = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))?.viewWithTag(1) as? UITextField
            
            textField?.resignFirstResponder()
        }
        
        if !self.validateFields() {
            
            return
        }
        
        
        let usernameTextField = self.tableView
            .cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?
            .viewWithTag(1) as! UITextField
        
        let emailTextField = self.tableView
            .cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?
            .viewWithTag(1) as! UITextField
        
        let passwordTextField = self.tableView
            .cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))?
            .viewWithTag(1) as! UITextField
        
        let user = User()
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        user.email = emailTextField.text
        
        User.signUp(user) { (user: User?, error: NSError?) -> Void in
            
            if let user = user where error == nil {
                
                self.loggedUser = user
                
                self.performSegueWithIdentifier("mainViewSegue", sender: self)
            }
            else if error != nil {
                
                let alert = UIAlertController(
                    title: "Error",
                    message: "Could not sign up",
                    preferredStyle: UIAlertControllerStyle.Alert)
                
                let action = UIAlertAction(
                    title: "Ok",
                    style: UIAlertActionStyle.Default,
                    handler: { (action: UIAlertAction!) -> Void in
                        
                })
                
                alert.addAction(action)
                
                self.presentViewController(
                    alert,
                    animated: true,
                    completion: { () -> Void in
                        
                        
                })
            }
        }
        
    }
}
