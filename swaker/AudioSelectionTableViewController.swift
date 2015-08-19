//
//  AudioLibraryTableViewController.swift
//  swaker
//
//  Created by William on 8/2/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import AVFoundation

//protocol AudioSelectionDelegate {
//    func controller(controller: AudioSelectionTableViewController, didSelectItem: NSData)
//}

class AudioSelectionTableViewController: UITableViewController {
    
    var audioPlayer:AVAudioPlayer!
    //a boleana abaixo serve para identificar de a view foi chamada a partir da RecordViewController
    //significando que deve ser permitido a selecao
    //este pode ser o array de audio recebidos ou de criados, depende da segment control
    var currentArray = [AudioSaved]()
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.setTitle("Received", forSegmentAtIndex: 0)
        segmentControl.setTitle("Created", forSegmentAtIndex: 1)
        
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
    
    @IBAction func CancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func indexChanged(sender: AnyObject) {
        if segmentControl.selectedSegmentIndex == 0 {
            currentArray = AudioDAO.sharedInstance().audioReceivedArray
        }
        else {
            currentArray = AudioDAO.sharedInstance().audioCreatedArray
        }
        
        tableView.reloadData()
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
        AudioDAO.sharedInstance().loadAllAudios()
        
        if segmentControl.selectedSegmentIndex == 0 {
            currentArray = AudioDAO.sharedInstance().audioReceivedArray
        }
        else {
            currentArray = AudioDAO.sharedInstance().audioCreatedArray
        }
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return currentArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! AudioCell
        
        if (segmentControl.selectedSegmentIndex == 0) {
            cell.textLabel?.text = AudioDAO.sharedInstance().audioReceivedArray[indexPath.row].audioDescription
            cell.audio = AudioDAO.sharedInstance().audioReceivedArray[indexPath.row].audio
            
        }
        else {
            cell.textLabel?.text = AudioDAO.sharedInstance().audioCreatedArray[indexPath.row].audioDescription
            cell.audio = AudioDAO.sharedInstance().audioCreatedArray[indexPath.row].audio
            
        }
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
    
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        
//        
//        if editingStyle == .Delete {
//            // Delete the row from the data source
//            //AudioDAO.sharedInstance().loadLocalAudios()
//            //nao precisa recarregar acho
//            if segmentControl.selectedSegmentIndex == 0 {
//                AudioDAO.sharedInstance().audioReceivedArray.removeAtIndex(indexPath.row)
//                
//            }
//            else {
//                AudioDAO.sharedInstance().audioCreatedArray.removeAtIndex(indexPath.row)
//            }
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        }
//    }
    
    /*
    Metodo para atribuir o audio associado a cell selecionada para a variavel selectedAudio
    Por fim retorna a RecordViewController
    Retorno: Void
    
    */
    
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
