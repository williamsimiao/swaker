//
//  ForgotPasswordViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 01/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var textFieldView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldView.layer.cornerRadius = 8
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 76/255, green: 187/255, blue: 255/255, alpha: 1.0).CGColor, UIColor(red: 255/255, green: 129/255, blue: 129/255, alpha: 1.0).CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submit(sender: AnyObject) {
        var alert = UIAlertController()
        let action = UIAlertAction(title: "OK", style:.Cancel) { (action) -> Void in
        }
        alert.addAction(action)
        if (count(emailTextField.text) > 4) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                if UserDAO.sharedInstance().resetPasswordForEmail(self.emailTextField.text) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        alert.message = "Your password reset has been sent to your email address."
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        alert.title = "Error"
                        alert.message = "Could not reset user password."
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                    
                }
            })
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
