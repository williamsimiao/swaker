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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.hidesWhenStopped = true
        // Do any additional setup after loading the view.
    }

    @IBAction func add(sender: AnyObject) {
        indicator.startAnimating()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let user = UserDAO.sharedInstance().userWithEmail(self.friendsEmailTextField.text) {
                if UserDAO.sharedInstance().addFriend(user) {
                    UserDAO.sharedInstance().loadFriendsForCurrentUser()
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
            self.indicator.stopAnimating()
            
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
