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
        if audioId != nil {
            object = PFObject(className: "Alarm", dictionary: ["audioId":audioId!, "description":alarmDescription, "fireDate":fireDate, "setterId":setterId])
        }
            return object
    }
    
    /***************************************************************************
        Função que salva localmente o alarme
        Parametro: Void
        Retorno: Sucesso ou não da operação.
    ***************************************************************************/
    func save() -> Bool {
        self.objectId = String(Alarm.primaryKey())
        let path = Alarm.DAO.alarmsPath.stringByAppendingPathComponent("\(self.objectId).alf")
        return NSKeyedArchiver.archivedDataWithRootObject(self).writeToFile(path, atomically: true)
    }
    
    /***************************************************************************
        Função que remove o alarme localmente
        Parametro: o objectId do alarme
        Retorno: Sucesso ou não da operação.
    ***************************************************************************/
    static func deleteAlarm(alarm:Alarm!) -> Bool {
        var error:NSError?
        let path = DAO.alarmsPath.stringByAppendingPathComponent("\(alarm.objectId).alf")
        let success = NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
        if !success {
            println(error?.localizedDescription)
            return false
        }
        return true
    }
    
    /***************************************************************************
        Função que adiciona um audio a um alarme
    ***************************************************************************/
}
