//
//  ViewController.swift
//  swaker
//
//  Created by William on 7/24/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let userquery = PFUser.query()?.whereKey("name", equalTo: "Andre").findObjects()!
        if let user = userquery!.first as? PFUser {
            let userr = User(user: user)
            PFUser.logOut()
            UserDAO.sharedInstance().login(userr)
        }
        println(PFUser.currentUser())
        // Do any additional setup after loading the view, typically from a nib.
//        let pfuser = PFUser.query()?.whereKey("username", equalTo: "andreanmasiro@live.com").findObjects()
        let user = UserDAO.sharedInstance().currentUser
//        UserDAO.sharedInstance().login(user)
        let users = PFUser.query()?.whereKey("name", equalTo: "g0y").findObjects()
        let heavz = users?.first as! PFUser
        UserDAO.sharedInstance().addFriend(User(user: heavz))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

