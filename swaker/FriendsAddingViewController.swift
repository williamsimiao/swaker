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
    var currentCalendar = NSCalendar.currentCalendar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("AddFriend", comment: "AddFriend")
        friendsEmailTextField.placeholder = NSLocalizedString("FriendsEmail", comment: "Friends Email")
        indicator.hidden = true
        setUpViews()
        // Do any additional setup after loading the view.
    }
    
    func setUpViews() {
        self.backgroundView = view
        self.backgroundView.frame = UIScreen.mainScreen().bounds
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.mainScreen().bounds
        let comps = currentCalendar.components(.CalendarUnitHour, fromDate: NSDate())
        let index = Int(round(Float(comps.hour == 0 ? 24 : comps.hour) / 3) - 1)
        gradientLayer.colors = mainColor()
        gradientLayer.locations = mainLocation()
        self.backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    @IBAction func add(sender: AnyObject) {
        
        var flag : Bool
        flag = true
        let indicator = self.indicator
        indicator.hidden = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            if let user = UserDAO.sharedInstance().userWithEmail(self.friendsEmailTextField.text) {
                var index: Int
                
                if user.email == UserDAO.sharedInstance().currentUser?.email{
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        let alert = UIAlertController(title: "attention", message: "You can add yourself!", preferredStyle: UIAlertControllerStyle.Alert)
                        let action = UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in
                        })
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    })
                    
                }
                else{
                    
                    for index = 0; index < UserDAO.sharedInstance().currentUser?.friends.count; ++index {
                        if UserDAO.sharedInstance().currentUser?.friends[index].email == user.email {
                            println("SAPORRA JA EXISTE")
                            flag = false
                            break
                        }
                    }
                    
                    if flag {
                        if UserDAO.sharedInstance().addFriend(user) {
                            UserDAO.sharedInstance().loadFriendsForCurrentUser()
                            AlarmDAO.sharedInstance().loadFriendsAlarms()
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.navigationController?.popViewControllerAnimated(true)
                            })
                        }
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            let alert = UIAlertController(title: "Could not add", message: "Friend already added ", preferredStyle: UIAlertControllerStyle.Alert)
                            let action = UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in
                            })
                            alert.addAction(action)
                            self.presentViewController(alert, animated: true, completion: nil)
                            
                        })
                    }
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
