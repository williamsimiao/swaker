//
//  AudioSelectionViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 08/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioSelectionDelegate {
    func controller(controller: AudioSelectionTableViewController, didSelectItem: NSData)
}

class AudioSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    var delegate: AudioSelectionDelegate?
    var audiosArray: [Audio]!
    var audioPlayer: AVAudioPlayer!
    var backgroundView: UIView!
    var naviBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        segmentControl.setTitle("Received", forSegmentAtIndex: 0)
        segmentControl.setTitle("Created", forSegmentAtIndex: 1)
        // Do any additional setup after loading the view.
    }
    
    func setUpViews() {
        tableView.alpha = 0.8
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
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func indexChanged(sender: AnyObject) {
        if segmentControl.selectedSegmentIndex == 0 {
            audiosArray = AudioDAO.sharedInstance().audioReceivedArray
        }
        else {
            audiosArray = AudioDAO.sharedInstance().audioCreatedArray
        }
        
        tableView.reloadData()
    }
    
    
    @IBAction func play(sender:AnyObject) {
        let cell = sender.superview as! AudioCell
        audioPlayer = AVAudioPlayer(data: cell.audio, error: nil)
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func viewWillAppear(animated: Bool) {
        AudioDAO.sharedInstance().loadAllAudios()
        
        if segmentControl.selectedSegmentIndex == 0 {
            audiosArray = AudioDAO.sharedInstance().audioReceivedArray
        }
        else {
            audiosArray = AudioDAO.sharedInstance().audioCreatedArray
        }
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return audiosArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! AudioCell
        var audioArray = [Audio]()
        if (segmentControl.selectedSegmentIndex == 0) {
            audioArray = AudioDAO.sharedInstance().audioReceivedArray
        } else {
            audioArray = AudioDAO.sharedInstance().audioCreatedArray
        }
        cell.audioNameLabel.text = audioArray[indexPath.row].audioDescription
        cell.audio = audioArray[indexPath.row].audio
        return cell
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