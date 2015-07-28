//
//  ViewController.swift
//  swaker
//
//  Created by William on 7/24/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        AlarmDAO.sharedInstance().loadUserAlarms()
        AlarmDAO.sharedInstance().addAlarm(Alarm(audioId: "aid", alarmDescription: "adesc", fireDate: NSDate(), setterId: PFUser.currentUser()?.objectId))
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

