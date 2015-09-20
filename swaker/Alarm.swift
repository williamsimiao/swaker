//
//  Alarm.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 27/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import Parse

class Alarm: NSObject, NSCoding {
    
    static let DAO = AlarmDAO.sharedInstance()
    static var key = 0
    
    static func primaryKey() -> String {
        return String(++key)
    }
    
    var objectId:String!
    var audioId:String? {
        didSet {
            self.toPFObject().save()
        }
    }
    var alarmDescription:String!
    var fireDate:NSDate!
    var setterId:String!
    
    init(audioId:String?, alarmDescription:String!, fireDate:NSDate, setterId:String!) {
        self.audioId = audioId
        self.alarmDescription = alarmDescription
        self.fireDate = fireDate
        self.setterId = setterId
    }
    
    override init () {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        objectId = aDecoder.decodeObjectForKey("objectId") as? String
        audioId = aDecoder.decodeObjectForKey("audioId") as? String
        alarmDescription = aDecoder.decodeObjectForKey("alarmDescription") as! String
        fireDate = aDecoder.decodeObjectForKey("fireDate") as! NSDate
        setterId = aDecoder.decodeObjectForKey("setterId") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(objectId, forKey: "objectId")
        aCoder.encodeObject(audioId, forKey: "audioId")
        aCoder.encodeObject(alarmDescription, forKey: "alarmDescription")
        aCoder.encodeObject(fireDate, forKey: "fireDate")
        aCoder.encodeObject(setterId, forKey: "setterId")
    }
    
    init(PFAlarm:PFObject) {
        self.objectId = PFAlarm.objectId
        self.audioId = PFAlarm["audioId"] as? String
        self.alarmDescription = PFAlarm["description"] as! String
        self.fireDate = PFAlarm["fireDate"] as! NSDate
        self.setterId = PFAlarm["setterId"] as! String
    }
    
    func toPFObject() -> PFObject {
        var object:PFObject!
        object = PFObject(className: "Alarm", dictionary: ["description":alarmDescription, "fireDate":fireDate, "setterId":setterId])
        if audioId != nil {
            object.setObject(audioId!, forKey: "audioId")
        }
        return object
    }
    
    /***************************************************************************
        Função que salva localmente o alarme
        Parametro: Void
        Retorno: Sucesso ou não da operação.
    ***************************************************************************/
    func save() -> Bool {
        if self.objectId == nil {
            self.objectId = String(Alarm.primaryKey())
        }
        let path = Alarm.DAO.alarmsPath.stringByAppendingPathComponent("\(self.objectId).alf")
        return NSKeyedArchiver.archivedDataWithRootObject(self).writeToFile(path, atomically: true)
    }
    
    /***************************************************************************
        Função que remove o alarme localmente
        Parametro: void
        Retorno: Sucesso ou não da operação.
    ***************************************************************************/
    func delete() -> Bool {
        var error:NSError?
        let path = AlarmDAO.sharedInstance().alarmsPath.stringByAppendingPathComponent("\(self.objectId).alf")
        let success = NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
        if !success {
            println(error?.localizedDescription)
            return false
        }
        self.unschedule()
        return true
    }
    
    func schedule() {
        let alarmNotification = UILocalNotification()
        
        alarmNotification.alertBody = self.alarmDescription
        alarmNotification.fireDate = NSDate(timeInterval: -NSTimeInterval(NSTimeZone.systemTimeZone().secondsFromGMT), sinceDate: self.fireDate)
        alarmNotification.userInfo = ["alarmId":self.objectId]
        alarmNotification.category = AppDelegate.categoriesIdentifiers.newAlarm.rawValue
        alarmNotification.soundName = ""
        UIApplication.sharedApplication().scheduleLocalNotification(alarmNotification)
    }
    
    func updateNotificationSound(soundName: String) {
        let notifs = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
        for notif in notifs {
            let userInfo = notif.userInfo as! [String: String]
            if userInfo["alarmId"] == self.objectId {
                notif.soundName = "propostaSound.caf"
//                UIApplication.sharedApplication().cancelLocalNotification(notif)
                UIApplication.sharedApplication().scheduleLocalNotification(notif)
                
            }
        }
    }
    
    func unschedule() {
        let notifs = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
        for notif in notifs {
            if let info = notif.userInfo as? [String:String] {
                if info["alarmId"] == self.objectId {
                    UIApplication.sharedApplication().cancelLocalNotification(notif)
                }
            }
        }
    }
}
