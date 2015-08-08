//
//  AlarmsViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 08/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class AlarmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Alarms"
        setUpViews()
        // Do any additional setup after loading the view.
    }
    
    func setUpViews() {
        tableView.alpha = 0.8
        self.backgroundView = view
        self.backgroundView.frame = UIScreen.mainScreen().bounds
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.mainScreen().bounds
        gradientLayer.colors = [UIColor(red: 76/255, green: 187/255, blue: 255/255, alpha: 1.0).CGColor, UIColor(red: 255/255, green: 129/255, blue: 129/255, alpha: 1.0).CGColor]
        self.backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        let naviBar = navigationController!.navigationBar
        naviBar.barStyle = UIBarStyle.Default
        naviBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        naviBar.shadowImage = UIImage()
        let backgroundView = UIView(frame: CGRect(x: 0, y: -20, width: naviBar.bounds.width, height: naviBar.bounds.height + 20))
        backgroundView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        naviBar.insertSubview(backgroundView, atIndex: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return AlarmDAO.sharedInstance().userAlarms.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = AlarmDAO.sharedInstance().userAlarms[indexPath.row].fireDate.description
        // Configure the cell...
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            AlarmDAO.sharedInstance().loadUserAlarms()
            if AlarmDAO.sharedInstance().deleteAlarm(AlarmDAO.sharedInstance().userAlarms[indexPath.row]) {
                AlarmDAO.sharedInstance().loadUserAlarms()
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "requestPermission" {
            let requestP = segue.destinationViewController as! RequestPermissionTableViewController
            
            let indexPath = self.tableView.indexPathForSelectedRow()
            
            requestP.alarm = AlarmDAO.sharedInstance().userAlarms[indexPath!.row]
            println("ALAREM ID"+requestP.alarm!.objectId)
            
            
        }
    }
}
