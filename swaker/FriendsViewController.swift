//
//  FriendsViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 08/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FriendsDataUpdating, AlarmDAODataUpdating {

    @IBOutlet weak var tableView: UITableView!
    var backgroundView: UIView!
    var naviBackgroundView: UIView!
    var currentCalendar = NSCalendar.currentCalendar()
    var hasInternet: Bool!
    var stopChecking: NSTimer!
    var internetChecking: NSTimer!
    var friends = [User]()
    var isDeleting = false
    var hasLoaded = false {
        didSet {
            if hasLoaded {
                navigationItem.titleView = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Friends"
        friends = UserDAO.sharedInstance().currentUser!.friends
        UserDAO.sharedInstance().currentUser!.friendsDelegate.append(self)
        AlarmDAO.sharedInstance().friendsAlarmsDelegate.append(self)
        setUpViews()
        
        println("ARRRRRRRRAAAY:\(self.navigationController?.viewControllers.count)     ")
    }
    
    func setUpViews() {
        tableView.alpha = 0.8
        self.backgroundView = view
        self.backgroundView.frame = UIScreen.mainScreen().bounds
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.mainScreen().bounds
        let comps = currentCalendar.components(.CalendarUnitHour, fromDate: NSDate())
        let index = Int(round(Float(comps.hour == 0 ? 24 : comps.hour) / 3) - 1)
        gradientLayer.colors = mainColors[index]
        gradientLayer.locations = mainLocations[index] as! [AnyObject]
        self.backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
        
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
        naviBar.titleTextAttributes = [NSForegroundColorAttributeName: navBarTintColor]
        
        let separator = UIView(frame: CGRect(x: 0, y: naviBar.frame.height, width: naviBar.frame.width, height: 0.5))
        separator.backgroundColor = separatorColor
        naviBar.addSubview(separator)
    }
    
    func reloadData() {
        friends = UserDAO.sharedInstance().currentUser!.friends
        if !isDeleting {
            tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    //ALTERADO
    func checkInternetConnection() {
        if Reachability.isConnectedToNetwork() == true {
            hasInternet = true
            println("achou net")
            internetChecking.invalidate()
            
        } else {
            hasInternet = false
            println("nao achou net")
        }
    }
    
    func stopInternetCheckingTimer() {
        println("ANTES")
        internetChecking.invalidate()
        println("DEPOIS")
        if hasInternet == true  {
            println("Internet connection OK")
            tableView.reloadData()
        } else {
            let alert = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (okAction) -> Void in
                //parar o activity indicator
            })
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        AlarmDAO.sharedInstance().loadFriendsAlarms()
        
        //checando se a internet a cada 0.5 segundo
        internetChecking = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkInternetConnection", userInfo: nil, repeats: true)
        
        //parando de o timer de checar por internet apos 4 segundos
        stopChecking = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: "stopInternetCheckingTimer", userInfo: nil, repeats: false)
        
    }
    //ALTERADO ATE AQUI

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! FriendsCell
        let friend = friends[indexPath.row]
        cell.nameLabel.text = friend.name
        cell.friend = friend
        cell.loadFriendInfo()
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
            isDeleting = true
            if UserDAO.sharedInstance().deleteFriend(UserDAO.sharedInstance().currentUser!.friends[indexPath.row]) {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                tableView.reloadData()
                isDeleting = false
            } else {
                println("failed to delete friend")
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "friendsAlarms" {
            (segue.destinationViewController as! FriendsAlarmsViewController).friend = friends[tableView.indexPathForSelectedRow()!.row]
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
