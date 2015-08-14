//
//  AlarmsViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 08/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class AlarmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    var backgroundView: UIView!
    var naviBackgroundView: UIView!
    var userAlarms = AlarmDAO.sharedInstance().userAlarms
    var currentCalendar = NSCalendar.currentCalendar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Alarms"
        tabBarController?.tabBar.tintColor = selectedTintColor
        setUpViews()
        currentCalendar.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        AlarmDAO.sharedInstance().loadUserAlarms()
        userAlarms = AlarmDAO.sharedInstance().userAlarms
        tableView.reloadData()
    }
    
    func setUpViews() {
        tableView.alpha = 0.8
        self.backgroundView = view
        self.backgroundView.frame = UIScreen.mainScreen().bounds
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.mainScreen().bounds
        let comps = NSCalendar.currentCalendar().components(.CalendarUnitHour, fromDate: NSDate())
        let index = Int(round(Float(comps.hour == 0 ? 24 : comps.hour) / 3) - 1)
        gradientLayer.colors = mainColors[index]
        gradientLayer.locations = mainLocations[index] as! [AnyObject]
        self.backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        let titleAttribute = [NSForegroundColorAttributeName: navBarTintColor]
        let naviBar = navigationController!.navigationBar
        naviBar.barStyle = UIBarStyle.Default
        naviBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        naviBar.shadowImage = UIImage()
        naviBackgroundView = UIView(frame: CGRect(x: 0, y: -20, width: naviBar.bounds.width, height: 20))
        naviBackgroundView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        naviBackgroundView.tag = 8001
        naviBar.addSubview(naviBackgroundView)
        naviBar.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        naviBar.tintColor = navBarTintColor
        naviBar.titleTextAttributes = titleAttribute
        
        tabBarItem.setTitleTextAttributes(titleAttribute, forState: UIControlState.Normal)
        let separator = UIView(frame: CGRect(x: 0, y: naviBar.frame.height, width: naviBar.frame.width, height: 0.5))
        separator.backgroundColor = separatorColor
        naviBar.addSubview(separator)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! AlarmCell
        let alarm = userAlarms[indexPath.row]
        let comps = currentCalendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: alarm.fireDate)
        cell.descriptionLabel.text = "\(alarm.alarmDescription)"
        cell.fireDateLabel.text = String(format: "%02d:%02d", arguments: [comps.hour, comps.minute])
        cell.accessoryType = .DisclosureIndicator
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
        if segue.identifier == "audioAttempts" {
            let vc = segue.destinationViewController as! AlarmsAudioAttemptViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            
            vc.alarm = AlarmDAO.sharedInstance().userAlarms[indexPath!.row]
            println("ALAREM ID"+vc.alarm!.objectId)
        }
        
    }
    
    
    
}
