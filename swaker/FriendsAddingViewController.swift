//
//  FriendsAddingViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 29/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class FriendsAddingViewController: UIViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var friendsEmailTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.hidden = true
        setUpViews()
        // Do any additional setup after loading the view.
    }
    
    func setUpViews() {
        self.backgroundView = view
        self.backgroundView.frame = UIScreen.mainScreen().bounds
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.mainScreen().bounds
        gradientLayer.colors = mainColors
        gradientLayer.locations = mainLocations
        self.backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    @IBAction func add(sender: AnyObject) {
        
        let indicator = self.indicator
        indicator.hidden = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            if let user = UserDAO.sharedInstance().userWithEmail(self.friendsEmailTextField.text) {
                if UserDAO.sharedInstance().addFriend(user) {
                    UserDAO.sharedInstance().loadFriendsForCurrentUser()
                    AlarmDAO.sharedInstance().loadFriendsAlarms()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                indicator.hidden = true
            })
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
