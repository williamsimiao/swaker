//
//  SettingsViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 09/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    var backgroundView: UIView!
    var naviBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        setUpViews()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logout(sender: AnyObject) {
        UserDAO.sharedInstance().logout()
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setUpViews() {
        self.backgroundView = view
        self.backgroundView.frame = UIScreen.mainScreen().bounds
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.mainScreen().bounds
        gradientLayer.colors = mainColors
        gradientLayer.locations = mainLocations
        self.backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        let naviBar = navigationController!.navigationBar
        naviBar.barStyle = UIBarStyle.Default
        naviBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        naviBar.shadowImage = UIImage()
        naviBackgroundView = UIView(frame: CGRect(x: 0, y: -20, width: naviBar.bounds.width, height: 20))
        naviBackgroundView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        naviBackgroundView.tag = 8001
        naviBar.addSubview(naviBackgroundView)
        naviBar.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        naviBar.tintColor = navBarTintColor
        naviBar.titleTextAttributes = [NSForegroundColorAttributeName: navBarTintColor]
        
        let separator = UIView(frame: CGRect(x: 0, y: naviBar.frame.height, width: naviBar.frame.width, height: 0.5))
        separator.backgroundColor = separatorColor
        naviBar.addSubview(separator)
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
