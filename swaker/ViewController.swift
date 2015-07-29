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
        // Do any additional setup after loading the view, typically from a nib.
        let query = PFQuery(className: "Alarm")
        let alarms = query.findObjects()!
        for alarm in alarms {
            AlarmDAO.sharedInstance().deleteAlarm(Alarm(PFAlarm: alarm as! PFObject))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

