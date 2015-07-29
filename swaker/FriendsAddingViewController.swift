//
//  FriendsAddingViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 29/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class FriendsAddingViewController: UIViewController {

    @IBOutlet weak var friendsEmailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func add(sender: AnyObject) {
        if let user = UserDAO.sharedInstance().userWithEmail(friendsEmailTextField.text) {
            if UserDAO.sharedInstance().addFriend(user) {
                UserDAO.sharedInstance().loadFriendsForCurrentUser()
                navigationController?.popViewControllerAnimated(true)
            }
        }
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
