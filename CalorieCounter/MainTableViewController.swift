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

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("updateEntries:"),
            name: Constants.Notifications.Storage.entriesUpdated,
            object: nil)

        if self.localUser == nil {
            
            self.localUser = User.currentUser()
        }
        
        entries = self.localUser.todaysEntries()
        
//        self.calories.extend(self.localUser?.calories.filter("eatenOn"))
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: actions
    
    func updateEntries(notification: NSNotification?) {
        
        self.entries = self.localUser.todaysEntries()
        
        self.tableView.reloadData()
    }
}
