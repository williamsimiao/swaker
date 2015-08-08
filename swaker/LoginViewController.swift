//
//  LoginViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 29/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var textFieldsView: UIView!
    var gradientLayer:CAGradientLayer!
    
    @IBOutlet weak var loginButtonYConstraint: NSLayoutConstraint!
    @IBOutlet weak var forgotPasswordButtonYConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        indicator.hidden = true
        indicator.startAnimating()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.textFieldsView.alpha = 1
        self.logInButton.alpha = 1
        self.forgotPasswordButton.alpha = 1
        self.signUpButton.alpha = 1

    }

    override func viewDidAppear(animated: Bool) {
        println(logInButton.frame)
    }
    
    func setUpViews() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = mainColors
        gradientLayer.locations = mainLocations
        view.layer.insertSublayer(gradientLayer, atIndex: 0)
        logInButton.layer.cornerRadius = 4
        logInButton.clipsToBounds = true
        textFieldsView.layer.cornerRadius = 4
        textFieldsView.clipsToBounds = true
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func login(sender: AnyObject) {
        lowerViews()
        let indicator = self.indicator
        let user = User(username: usernameTextField.text, password: passwordTextField.text)
        indicator.hidden = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            if UserDAO.sharedInstance().login(user) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.performSegueWithIdentifier("loginSucceeded", sender: self)
                    UserDAO.sharedInstance().loadFriendsForCurrentUser()
                    AlarmDAO.sharedInstance().loadUserAlarms()
                    AlarmDAO.sharedInstance().loadFriendsAlarms()
                    AlarmDAO.sharedInstance().deleteCloudAlarmsIfNeeded()
                    AlarmDAO.sharedInstance().subscribeToAlarms()
                    self.clearTextFields()
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
    
    func clearTextFields() {
        self.usernameTextField.text = ""
        self.passwordTextField.text = ""
    }
    
    @IBAction func forgotYourPassword(sender:AnyObject) {
        let delaytime = NSTimeInterval(0.2)
        UIView.animateWithDuration(delaytime, animations: { () -> Void in
            self.textFieldsView.alpha = 0
            self.logInButton.alpha = 0
            self.forgotPasswordButton.alpha = 0
            self.signUpButton.alpha = 0
        })
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delaytime * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.performSegueWithIdentifier("forgotPassword", sender: self)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if loginButtonYConstraint.constant != view.frame.height * 0.15 {
            loginButtonYConstraint.constant = view.frame.height * 0.15
            forgotPasswordButtonYConstraint.constant += view.frame.height * 2/5
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func clickOnBackground(sender:AnyObject) {
        lowerViews()
    }
    
    func lowerViews() {
        if usernameTextField.isFirstResponder() || passwordTextField.isFirstResponder() {
            forgotPasswordButtonYConstraint.constant -= view.frame.height * 2/5
        }
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        loginButtonYConstraint.constant = 0
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
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
