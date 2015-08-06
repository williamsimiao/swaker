//
//  ViewController.swift
//  swaker
//
//  Created by William on 7/24/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                self.indicator.stopAnimating()
                self.performSegueWithIdentifier("userAlreadyLoggedIn", sender: self)
            })
        }
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

