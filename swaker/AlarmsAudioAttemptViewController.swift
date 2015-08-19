//
//  AlarmsAudioAttemptViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 09/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class AlarmsAudioAttemptViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var audioAttemptArray = AudioDAO.sharedInstance().audioTemporaryArray
    var backgroundView: UIView!
    var alarm: Alarm!
    var currentCalendar = NSCalendar.currentCalendar()
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        AudioDAO.sharedInstance().loadAudiosFromAlarm(alarm)
        audioAttemptArray = AudioDAO.sharedInstance().audioTemporaryArray
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        AudioDAO.sharedInstance().loadAudiosFromAlarm(alarm)
        tableView.reloadData()
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  audioAttemptArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! AudioAttemptCell
        cell.audioNameLabel.text = "\(audioAttemptArray[indexPath.row].audioDescription!)"
        if let friend = UserDAO.sharedInstance().currentUser!.friendWithObjectId(audioAttemptArray[indexPath.row].senderId) {
            cell.senderNameLabel.text = friend.name
        }
        cell.audioAttempt = audioAttemptArray[indexPath.row]
        
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
