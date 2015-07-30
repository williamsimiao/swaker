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
        // Do any additional setup after loading the view, typically from a nib.
        
        println("UserId:\(PFUser.currentUser()?.objectId)")
        
        println("lets subricribe to channel")
        
        let currentInstallation = PFInstallation.currentInstallation()
       
        let friendsQuery = PFQuery(className: "FrindList")
        friendsQuery.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
        let arrayDeFriends = friendsQuery.findObjects()!
        
        var channels = [String]()
        
        for friendObject in arrayDeFriends {
            
            let frindId = friendObject["friendId"] as! String
            currentInstallation.addUniqueObject(frindId, forKey: "channels")
            channels.append(frindId)

        }
        currentInstallation.saveInBackground()

        //fim do subscribe
        
        let butao = UIButton(frame: CGRectMake(200, 200, 200, 200))
        butao.setTitleColor(UIColor.blackColor(), forState: .Normal)
        butao.setTitle("push me", forState: UIControlState.Normal)
        butao.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(butao)
        
    }
    
    /*
        
    */
    func pressed(sender: UIButton, channels: Array<String>) {
        
        println("sending a push")
        
        let push = PFPush()
        
        // Be sure to use the plural 'setChannels'.
        push.setChannels(channels)
        push.setMessage("The Giants won against the Mets 2-3.")
        push.sendPushInBackground()
        

        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

