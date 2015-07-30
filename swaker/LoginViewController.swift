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
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDAO.sharedInstance().logout()
        indicator.hidesWhenStopped = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: AnyObject) {
        let user = User(username: usernameTextField.text, password: passwordTextField.text)
        indicator.startAnimating()
        println(indicator.isAnimating())
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if UserDAO.sharedInstance().login(user) {
                self.performSegueWithIdentifier("loginSucceeded", sender: self)
                UserDAO.sharedInstance().loadFriendsForCurrentUser()
            } else {
                let alert = UIAlertController(title: "Incorrect Informtions", message: "Email and/or password is incorrect.", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in
                })
                alert.addAction(action)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.indicator.stopAnimating()
        })
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
