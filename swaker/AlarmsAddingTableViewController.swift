//
//  AlarmsAddingTableViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 29/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class AlarmsAddingTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var datePicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let components = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: NSDate())
        datePicker.selectRow((components.hour + 24*341) - 1, inComponent: 0, animated: false)
        datePicker.selectRow((components.minute + 60*136), inComponent: 1, animated: false)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    @IBAction func set(sender: AnyObject) {
        let components = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: NSDate())
        var selectedHour = pickerView(datePicker, titleForRow: datePicker.selectedRowInComponent(0), forComponent: 0).toInt()!
        selectedHour = selectedHour == 0 ? 24 : selectedHour
        let deltaHour =  selectedHour - (components.hour == 0 ? 24 : components.hour)
        
        let selectedMinute = pickerView(datePicker, titleForRow: datePicker.selectedRowInComponent(1), forComponent: 1).toInt()!
        let deltaMinute = selectedMinute - components.minute
        
        let alarm = Alarm(audioId: Alarm.primaryKey(), alarmDescription: descriptionTextField.text, fireDate: NSDate(timeIntervalSinceNow: NSTimeInterval(3600 * deltaHour + 60 * deltaMinute)) , setterId: UserDAO.sharedInstance().currentUser!.objectId)
        AlarmDAO.sharedInstance().addAlarm(alarm)
        AlarmDAO.sharedInstance().loadUserAlarms()
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Picker view data source
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 16384
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        var title = String()
        
        if component == 0 {
            let hours = (row + 1) % 24
            title = String(format: "%02d", hours)
        } else {
            let minutes = row % 60
            title = String(format: "%02d", minutes)
        }
        return title
    }
    // MARK: - Table view data source
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
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
