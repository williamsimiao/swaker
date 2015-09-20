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
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var gradientLayer:CAGradientLayer!
    var currentCalendar = NSCalendar.currentCalendar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.hidden = true
        textFieldView.layer.cornerRadius = 4
        submitButton.layer.cornerRadius = 4
        submitButton.setTitle(NSLocalizedString("Submit", comment: "Submit"), forState: .Normal)
        doneButton.setTitle(NSLocalizedString("Done", comment: "Done"), forState: .Normal)
        setUpViews()
        // Do any additional setup after loading the view.
    }
    
    func setUpViews() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        let comps = currentCalendar.components(.CalendarUnitHour, fromDate: NSDate())
        let index = Int(round(Float(comps.hour == 0 ? 24 : comps.hour) / 3) - 1)
        gradientLayer.colors = mainColor()
        gradientLayer.locations = mainLocation()
        view.layer.insertSublayer(gradientLayer, atIndex: 0)

    }
    
    override func viewWillAppear(animated: Bool) {
        submitButton.alpha = 0
        textFieldView.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.submitButton.alpha = 1
            self.textFieldView.alpha = 1
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submit(sender: AnyObject) {
        var alert = UIAlertController(title: nil, message: nil, preferredStyle:.Alert)
        let action = UIAlertAction(title: "OK", style:.Cancel) { (action) -> Void in
            self.emailTextField.text = ""
        }
        alert.addAction(action)
        if (count(emailTextField.text) > 4) {
            indicator.hidden = false
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                let resetPasswordResult = UserDAO.sharedInstance().resetPasswordForEmail(self.emailTextField.text)
                if resetPasswordResult.success {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        alert.message = NSLocalizedString("PasswordResetSent", comment: "Password")
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.indicator.hidden = true
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        alert.title = NSLocalizedString("Error", comment: "Error")
                        alert.message = NSLocalizedString("CouldntReset", comment: "Password")
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.indicator.hidden = true
                    })
                }
            })
        } else {
            alert.message = NSLocalizedString("TypeSomething", comment: "Password")
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backgroundTap(sender: AnyObject) {
        emailTextField.resignFirstResponder()
    }
    
    @IBAction func done(sender:AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
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
