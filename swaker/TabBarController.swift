//
//  TabBarController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 08/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        for item in tabBar.items! {
            let item = item as! UITabBarItem
            item.image = item.image?.imageWithRenderingMode(.AlwaysOriginal)
            item.setTitleTextAttributes([NSForegroundColorAttributeName:navBarTintColor], forState: UIControlState.Normal)
            item.setTitleTextAttributes([NSForegroundColorAttributeName:selectedTintColor], forState: UIControlState.Highlighted)
        }
        // Do any additional setup after loading the view.
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
