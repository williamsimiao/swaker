//
//  AudioLibraryTableViewController.swift
//  swaker
//
//  Created by William on 8/2/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import AVFoundation


class AudioLibraryTableViewController: UITableViewController {
    
    var audioPlayer:AVAudioPlayer!
    var allowAudioSelection: Bool!

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.setTitle("Received", forSegmentAtIndex: 0)
        segmentControl.setTitle("Sended", forSegmentAtIndex: 1)
        //setei para a segunda ser a defult

        navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 127/255, blue: 102/255, alpha: 1.0)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func indexChanged(sender: AnyObject) {
    }
    

    @IBAction func play(sender:AnyObject) {
        let cell = sender.superview as! AudioCell
        audioPlayer = AVAudioPlayer(data: cell.audio, error: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func viewWillAppear(animated: Bool) {
        AudioDAO.sharedInstance().loadLocalAudios()
        tableView.reloadData()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return AudioDAO.sharedInstance().audioSavedArray.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! AudioCell
        //cell.textLabel?.text = AudioDAO.sharedInstance().audioSavedArray[indexPath.row].audioName
        cell.audio = AudioDAO.sharedInstance().audioSavedArray[indexPath.row].audio
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */
    
    // Override to support editing the table view.

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if editingStyle == .Delete {
            // Delete the row from the data source
            //AudioDAO.sharedInstance().loadLocalAudios()
            //nao precisa recarregar acho
            if AudioDAO.sharedInstance().deleteAudioSaved(AudioDAO.sharedInstance().audioSavedArray[indexPath.row]) {
                AlarmDAO.sharedInstance().loadUserAlarms()
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
    }

    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
