//
//  AlarmsAddingViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 08/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import Parse

class AlarmsAddingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var timePicker: UIPickerView!
    var backgroundView: UIView!
    
    var currentCalendar = NSCalendar.currentCalendar()
    
    enum categoriesIdentifiers:String{
        case proposal = "PROPOSAL_CATEGORY"
        case newAlarm = "NEWALARM_CATEGORY"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        navigationItem.title = "Add an Alarm"
        timePicker.showsSelectionIndicator = false
        let components = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: NSDate())
        timePicker.selectRow((components.hour + 24*341) - 1, inComponent: 0, animated: false)
        timePicker.selectRow((components.minute + 60*136), inComponent: 2, animated: false)
        currentCalendar.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    }
    
    func setUpViews() {
        self.backgroundView = view
        self.backgroundView.frame = UIScreen.mainScreen().bounds
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.mainScreen().bounds
        let comps = NSCalendar.currentCalendar().components(.CalendarUnitHour, fromDate: NSDate())
        let index = Int(round(Float(comps.hour == 0 ? 24 : comps.hour) / 3) - 1)
        gradientLayer.colors = mainColors[index]
        gradientLayer.locations = mainLocations[index] as! [AnyObject]
        self.backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    @IBAction func set(sender: AnyObject) {
        
        let fireDate = dateFromPickerView()
        
        let alarm = Alarm(audioId: Alarm.primaryKey(), alarmDescription: descriptionTextField.text, fireDate: fireDate , setterId: UserDAO.sharedInstance().currentUser!.objectId)
        
        let addAlarmResult = AlarmDAO.sharedInstance().addAlarm(alarm)
        if addAlarmResult.success {
            ///dando o push pro setter receber a notificacao
            let myUserDAO = UserDAO.sharedInstance()
            let data = [
                "category" : categoriesIdentifiers.newAlarm.rawValue,
                "alert" : "Novo alarme de \(myUserDAO.currentUser!.name)",
                "badge" : "Increment",
                "sounds" : "paidefamilia.mp3",
                "f" : alarm.objectId
            ]
            
            let push = PFPush()
            push.expireAtDate(alarm.fireDate)
            push.setChannel("f" + alarm.setterId)
            push.setData(data)
            push.sendPushInBackground()
            navigationController?.popViewControllerAnimated(true)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "It was not possible to set the alarm. Try again later.", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func dateFromPickerView() -> NSDate {
        let components = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: NSDate())
        var selectedHour = pickerView(timePicker, attributedTitleForRow: timePicker.selectedRowInComponent(0), forComponent: 0)!.string.toInt()!
        selectedHour = selectedHour == 0 ? 24 : selectedHour
        
        let selectedMinute = pickerView(timePicker, attributedTitleForRow: timePicker.selectedRowInComponent(2), forComponent: 2)!.string.toInt()!
        
        if (selectedHour < components.hour) || ((selectedHour == components.hour) && (selectedMinute <= components.minute)) {
            components.day++
        }
        
        components.hour = selectedHour
        components.minute = selectedMinute
        
        return currentCalendar.dateFromComponents(components)!
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
