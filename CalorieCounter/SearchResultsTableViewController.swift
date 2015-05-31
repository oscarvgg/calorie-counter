//
//  SearchResultsTableViewController.swift
//  CalorieCounter
//
//  Created by Oscar Vicente González Greco on 30/5/15.
//  Copyright (c) 2015 Oscarvgg. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {
    
    var configuration: [String : NSDate] = [:]
    
    var entries: [Calorie] = []
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("updateEntries:"),
            name: Constants.Notifications.Storage.entriesUpdated,
            object: nil)

        self.updateEntries(nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: Constants.Notifications.Storage.entriesUpdated,
            object: nil)
    }

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.entries.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("entryCell", forIndexPath: indexPath) as! UITableViewCell
        
        let foodNameLabel = cell.viewWithTag(1) as! UILabel
        let caloriesLabel = cell.viewWithTag(2) as! UILabel
        let dateLabel = cell.viewWithTag(3) as! UILabel
        
        let entry: Calorie = self.entries[indexPath.row]
        
        foodNameLabel.text = entry.text
        caloriesLabel.text = String(entry.value)
        
        let formatedDate = NSDateFormatter.localizedStringFromDate(
            entry.eatenOn,
            dateStyle: NSDateFormatterStyle.MediumStyle,
            timeStyle: NSDateFormatterStyle.ShortStyle)
        
        dateLabel.text = formatedDate
        
        return cell
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let entry = self.entries[indexPath.row]
        
        self.performSegueWithIdentifier("editEntrySegue", sender: entry)
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
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 60;
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "editEntrySegue" {
            
            if let entry = sender as? Calorie {
                
                let navigation = segue.destinationViewController as! UINavigationController
                let newEntryViewController = navigation.viewControllers.first as! NewEntryTableViewController
                
                newEntryViewController.newEntry = entry
            }
        }
    }

    // MARK: - Actions
    
    func updateEntries(notification: NSNotification?) {
        
        let localUser = User.currentUser()
        
        if let fromDate = self.configuration["fromDate"], toDate = self.configuration["toDate"] {
            
            let dateRange = (fromDate, toDate)
            var timeRange:(Int, Int, Int, Int) = (0, 0, 23, 59)
            
            if let fromTime = self.configuration["fromTime"], toTime = self.configuration["toTime"] {
                
                let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
                let fromComponents = calendar.components(
                    NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute,
                    fromDate: fromTime)
                
                let toComponents = calendar.components(
                    NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute,
                    fromDate: toTime)
                
                timeRange = (
                    fromComponents.hour,
                    fromComponents.minute,
                    toComponents.hour,
                    toComponents.minute
                )
            }
            
            self.entries = localUser!.caloriesInRange(dateRange, timeRange: timeRange)
        }
        
        self.tableView.reloadData()
    }
}
