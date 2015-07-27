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
        let user = PFUser.logInWithUsername("andreanmasiro@live.com", password: "1234")
        let query = PFQuery(className: "Alarm")
//        let objs = query.findObjects() as? Array<PFObject>
        query.findObjectsInBackgroundWithBlock { (let array, let error) -> Void in
            if let array = array {
                for obj in array {
                    println(obj.objectId)
                }
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

