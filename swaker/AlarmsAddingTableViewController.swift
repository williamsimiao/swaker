//
//  AlarmsAddingTableViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 29/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import Parse


class AlarmsAddingTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var datePicker: UIPickerView!
    var currentCalendar = NSCalendar.currentCalendar()
    
    enum categoriesIdentifiers:String{
        //notificacao de nova proposta de audio
        case proposal = "PROPOSAL_CATEGORY"
        //notificacao de amigo setou novo alarme, nao necessita de actions
        case newAlarm = "NEWALARM_CATEGORY"
        
        // nao precisa de category pra notification de audio aceito
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.showsSelectionIndicator = false
        let components = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: NSDate())
        datePicker.selectRow((components.hour + 24*341) - 1, inComponent: 0, animated: false)
        datePicker.selectRow((components.minute + 60*136), inComponent: 2, animated: false)
        currentCalendar.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    @IBAction func set(sender: AnyObject) {
        let components = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: NSDate())
        var selectedHour = pickerView(datePicker, attributedTitleForRow: datePicker.selectedRowInComponent(0), forComponent: 0)!.string.toInt()!
        selectedHour = selectedHour == 0 ? 24 : selectedHour
        
        let selectedMinute = pickerView(datePicker, attributedTitleForRow: datePicker.selectedRowInComponent(2), forComponent: 2)!.string.toInt()!
        
        if (selectedHour < components.hour) || ((selectedHour == components.hour) && (selectedMinute <= components.minute)) {
            components.day++
        }
        
        components.hour = selectedHour
        components.minute = selectedMinute
        
        let fireDate = currentCalendar.dateFromComponents(components)!
        
        let alarm = Alarm(audioId: Alarm.primaryKey(), alarmDescription: descriptionTextField.text, fireDate: fireDate , setterId: UserDAO.sharedInstance().currentUser!.objectId)
        AlarmDAO.sharedInstance().addAlarm(alarm)
        
        ///dando o push pro setter receber a notificacao
        let myUserDAO = UserDAO.sharedInstance()
        let data = [
            "category" : categoriesIdentifiers.newAlarm.rawValue,
            "alert" : "Novo alarme de \(myUserDAO.currentUser!.name)",
            "badge" : "Increment",
            "sounds" : "paidefamilia.mp3",
        ]
        
        let push = PFPush()
        push.expireAtDate(alarm.fireDate)
        push.setChannel("a" + alarm.objectId)
        push.setData(data)
        push.sendPushInBackground()
        /////fim do push
        
        
        
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Picker view data source
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 || component == 2 {
            return 16384
        }
        return 0
    }

//    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
//        var title = String()
//        
//        if component == 0 {
//            let hours = (row + 1) % 24
//            title = String(format: "%02d", hours)
//        } else {
//            let minutes = row % 60
//            title = String(format: "%02d", minutes)
//        }
//        return title
//    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let pStyle = NSMutableParagraphStyle()
        pStyle.tailIndent = 150
        var title = String()
        if component == 0 {
            let hours = (row + 1) % 24
            title = String(format: "%02d", hours)
            pStyle.alignment = .Right
        } else if component == 2 {
            let minutes = row % 60
            title = String(format: "%02d", minutes)
            pStyle.alignment = .Left
        }
        return NSAttributedString(string: title, attributes: [NSParagraphStyleAttributeName:pStyle])
    }
    
//    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        println(view.frame.size)
//        let total = view.frame.size.width
//        let mid:CGFloat = 10
//        let firstAndLast = (total - mid) / 2
//        if component == 1 {
//            return mid
//        }
//        return firstAndLast
//    }
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
