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
    var currentCalendar = NSCalendar.currentCalendar()
    
    @IBOutlet weak var loginButtonYConstraint: NSLayoutConstraint!
    @IBOutlet weak var forgotPasswordButtonYConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.placeholder = NSLocalizedString("Email", comment: "Email")
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "Password")
        logInButton.setTitle(NSLocalizedString("Login", comment: "Login"), forState: UIControlState.Normal)
        signUpButton.setTitle(NSLocalizedString("Signup", comment: "Signup"), forState: .Normal)
        //signUpButton.setNeedsLayout()
        //signUpButton.layoutIfNeeded()
        forgotPasswordButton.setTitle(NSLocalizedString("ForgotPassword", comment: "Forgot Password"), forState: .Normal)
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
    
    func setUpViews() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        let comps = currentCalendar.components(.CalendarUnitHour, fromDate: NSDate())
        let index = Int(round(Float(comps.hour == 0 ? 24 : comps.hour) / 3) - 1)
        gradientLayer.colors = mainColors[index]
        gradientLayer.locations = mainLocations[index] as! [AnyObject]
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
            let loginResult = UserDAO.sharedInstance().login(user)
            if loginResult.success {
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
                    let alert = UIAlertController(title: NSLocalizedString("CouldntLogin", comment: "Couldnt Login"), message: loginResult.errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
