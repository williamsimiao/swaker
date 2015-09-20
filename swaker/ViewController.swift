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

    @IBOutlet weak var testeInter: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var gradientLayer:CAGradientLayer!
    var currentCalendar = NSCalendar.currentCalendar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()

    }

    override func viewDidAppear(animated: Bool) {
        if UserDAO.sharedInstance().currentUser == nil {
            performSegueWithIdentifier("loginScreen", sender: self)
        } else {
            indicator.startAnimating()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UserDAO.sharedInstance().loadFriendsForCurrentUser()
                AlarmDAO.sharedInstance().loadUserAlarms()
                AlarmDAO.sharedInstance().loadFriendsAlarms()
                AlarmDAO.sharedInstance().deleteCloudAlarmsIfNeeded()
                AudioDAO.sharedInstance().loadAllAudios()
                self.indicator.stopAnimating()
                self.performSegueWithIdentifier("loggedIn", sender: self)
            })
        }
    }
    
    override func performSegueWithIdentifier(identifier: String?, sender: AnyObject?) {
        super.performSegueWithIdentifier(identifier, sender: sender)
    }
    
    func setUpViews() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        let comps = currentCalendar.components(.CalendarUnitHour, fromDate: NSDate())
        let index = Int(round(Float(comps.hour == 0 ? 24 : comps.hour) / 3) - 1)
        gradientLayer.colors = mainColor()
        gradientLayer.locations = mainLocation()
        view.layer.insertSublayer(gradientLayer, atIndex: 0)
        indicator.hidesWhenStopped = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "userAlreadyLoggedIn" {
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
}

