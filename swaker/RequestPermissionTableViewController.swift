//
//  RequestPermissionTableViewController.swift
//  swaker
//
//  Created by Joao Paulo Lopes da Silva on 30/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class RequestPermissionTableViewController: UITableViewController {
    
    let audioDAO = AudioDAO.sharedInstance()
    var audiosArray  = [AudioAttempt]()
    var alarm : Alarm?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        audiosArray = audioDAO.loadAudiosFromAlarm(alarm!.objectId)
        
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

        return  audiosArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! RequestPTableViewCell
        
        cell.textLabel?.text = "\(audiosArray[indexPath.row].audioName)"
        

        return cell

    }
    
}
