//
//  TabBarController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 08/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    //Identificadores para as categorias
    enum categoriesIdentifiers:String{
        //notificacao de nova proposta de audio
        case proposal = "PROPOSAL_CATEGORY"
        //notificacao de amigo setou novo alarme, nao necessita de actions
        case newAlarm = "NEWALARM_CATEGORY"
        //notificacao local de acordar
        case wakeUp = "WAKEUP_CATEGORY"
        
        // nao precisa de category pra notification de audio aceito
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("presentAlert:"),
            name: "RecebeuInAppNotification",
            object: nil)
        for item in tabBar.items! {
            let item = item as! UITabBarItem
            item.image = item.image?.imageWithRenderingMode(.AlwaysOriginal)
            item.setTitleTextAttributes([NSForegroundColorAttributeName:navBarTintColor], forState: UIControlState.Normal)
            item.setTitleTextAttributes([NSForegroundColorAttributeName:selectedTintColor], forState: UIControlState.Highlighted)
        }
        // Do any additional setup after loading the view.
    }
    
    func presentAlert(sender: AnyObject) {
        let not = sender as! NSNotification
        let userInfo = not.userInfo as! [String: AnyObject]
        println(userInfo)
        let notificationPayload = userInfo["aps"] as! NSDictionary
        //creating alert for both categories
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        if notificationPayload["category"] as! String == categoriesIdentifiers.newAlarm.rawValue {
            alert.title = "New Alarm"
            alert.message = notificationPayload["alert"] as? String
        } else {
            if notificationPayload["category"] as! String == categoriesIdentifiers.proposal.rawValue {
                alert.title = "New audio proposal"
                alert.message = notificationPayload["alert"] as? String
            }
        }
        let title = notificationPayload["alert"] as! String
        
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
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
