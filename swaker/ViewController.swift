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

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var gradientLayer:CAGradientLayer!
    
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
                self.performSegueWithIdentifier("userAlreadyLoggedIn", sender: self)
            })
        }
    }
    
    func setUpViews() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 76/255, green: 187/255, blue: 255/255, alpha: 1.0).CGColor, UIColor(red: 255/255, green: 129/255, blue: 129/255, alpha: 1.0).CGColor]
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

