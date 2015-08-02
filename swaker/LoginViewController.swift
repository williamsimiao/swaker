//
//  LoginViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 29/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var textFieldsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 76/255, green: 187/255, blue: 255/255, alpha: 1.0).CGColor, UIColor(red: 255/255, green: 129/255, blue: 129/255, alpha: 1.0).CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
        logInButton.layer.cornerRadius = 8
        logInButton.clipsToBounds = true
        textFieldsView.layer.cornerRadius = 8
        textFieldsView.clipsToBounds = true
        // Do any additional setup after loading the view.
        indicator.hidden = true
        indicator.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func login(sender: AnyObject) {
        let indicator = self.indicator
        let user = User(username: usernameTextField.text, password: passwordTextField.text)
        indicator.hidden = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            if UserDAO.sharedInstance().login(user) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.performSegueWithIdentifier("loginSucceeded", sender: self)
                    UserDAO.sharedInstance().loadFriendsForCurrentUser()
                    AlarmDAO.sharedInstance().loadUserAlarms()
                    AlarmDAO.sharedInstance().deleteLocalAlarmsIfNeeded()
                    (UIApplication.sharedApplication().delegate as! AppDelegate).subscribe()
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alert = UIAlertController(title: "Could not Log In", message: "Email and/or password is incorrect.", preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in
                    })
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                indicator.hidden = true
            })
        })
    }

    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
