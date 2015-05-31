//
//  MainTableViewController.swift
//  CalorieCounter
//
//  Created by Oscar Vicente González Greco on 17/5/15.
//  Copyright (c) 2015 Oscarvgg. All rights reserved.
//

import UIKit
import RealmSwift

class MainTableViewController: UITableViewController {
    
    
    var localUser: User!
    
    var entries: [Calorie] = []

    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var caloryCountLabel: UILabel!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("updateEntries:"),
            name: Constants.Notifications.Storage.entriesUpdated,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("updateEntries:"),
            name: Constants.Notifications.Storage.newEntryAdded,
            object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("updateEntries:"),
            name: Constants.Notifications.Storage.maxDailyCaloriesUpdated,
            object: nil)

        if self.localUser == nil {
            
            self.localUser = User.currentUser()
        }
        
        self.navigationController?.viewControllers = [self]
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.updateEntries(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return entries.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("entryCell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = self.entries[indexPath.row].text
        cell.detailTextLabel?.text = String(self.entries[indexPath.row].value)

        return cell
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let entry = self.entries[indexPath.row]
        
        self.performSegueWithIdentifier("newEntrySegue", sender: entry)
    }
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action: UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            self.tableView(self.tableView!, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
        }
        
        return [deleteAction]
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if (editingStyle == .Delete)
        {
            self.entries[indexPath.row].delete(Calorie.self, completion: { (succeeded: Bool, error: NSError?) -> Void in
                
                if !succeeded {
                    return
                }
                
                self.updateEntries(nil)
            })
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "newEntrySegue" {
            
            if let entry = sender as? Calorie {
                
                let navigation = segue.destinationViewController as! UINavigationController
                let newEntryViewController = navigation.viewControllers.first as! NewEntryTableViewController
                
                newEntryViewController.newEntry = entry
            }
        }
    }
    
    
    // MARK: actions
    
    func updateEntries(notification: NSNotification?) {
        
        self.entries = self.localUser.todaysEntries()
        
        let todayValue = self.localUser.todayValue()
        let maxCount = self.localUser.maxDailyCalorieCount
        
        self.progressView.progress = todayValue
        self.progressView.totalValue = maxCount
        
        self.caloryCountLabel.text = "\(todayValue) \n / \(maxCount)"
        
        self.tableView.reloadData()
    }
}
