//
//  AlarmDAO.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 27/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import Parse

class AlarmDAO: NSObject {
    
    static var instance:AlarmDAO?
    
    var alarmsPath:String! {
        didSet { // Verifica se a pasta existe e, caso não exista, cria-a.
            if !NSFileManager.defaultManager().fileExistsAtPath(self.alarmsPath) {
                var error:NSError?
                NSFileManager.defaultManager().createDirectoryAtPath(self.alarmsPath, withIntermediateDirectories: false, attributes: nil, error: &error)
                if error != nil {
                    println(error?.localizedDescription)
                }
            }
        }
    }
    
    let user = PFUser.currentUser()!
    var userAlarms = [Alarm]()
    var friendsAlarms = [Alarm]()
    
    static func sharedInstance() -> AlarmDAO {
        if instance == nil {
            instance = AlarmDAO()
            let docs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
            instance?.alarmsPath = docs.stringByAppendingPathComponent("Alarms")
            println(instance?.alarmsPath)
        }
        return instance!
    }
    /***************************************************************************
        Função que carrega todos os alarmes para o usuário logado.
        Devolve um array de alarmes para a propriedade self.userAlarms
        Parâmetro: Void
        Retorno: Void
    ***************************************************************************/
    func loadUserAlarms() {
        let enumerator = NSFileManager.defaultManager().enumeratorAtPath(self.alarmsPath)
        while let alarm:String = enumerator?.nextObject() as? String{
            if alarm.hasSuffix("alf") {
                let filePath = alarmsPath.stringByAppendingPathComponent(alarm)
                let data = NSData(contentsOfFile: filePath)
                let alarm = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! Alarm
                userAlarms.append(alarm)
            }
        }
    }
    
    /***************************************************************************
        Função que carrega os alarmes dos amigos
        Devolve um array de alarmes para a propriedade self.friendsAlarms
        Parâmetro: Void
        Retorno: Void
    ***************************************************************************/
    func loadFriendsAlarms() {
        let bigQuery = PFQuery(className: "Alarm")
        if let user = UserDAO.sharedInstance().currentUser {
            for friend in user.friends! {
                let query = bigQuery.whereKey("setterId", equalTo: friend.objectId)
                let alarms = query.findObjects() as? Array<PFObject>
                if alarms != nil {
                    for alarm in alarms! {
                        friendsAlarms.append(Alarm(PFAlarm: alarm))
                    }
                }
            }
        }
    }
    
    /***************************************************************************
        Função que adiciona um novo alarme
        Parâmetro: Void
        Retorno: Void
    ***************************************************************************/
    func addAlarm(alarm:Alarm) {
        var alarmId:String!
        let PFAlarm = PFObject(className: "Alarm")
        PFAlarm.setObject(alarm.fireDate, forKey: "fireDate")
        PFAlarm.setObject(alarm.audioId, forKey: "audioId")
        PFAlarm.setObject(alarm.setterId, forKey: "setterId")
        PFAlarm.setObject(alarm.alarmDescription, forKey: "description")
        if (PFAlarm.save()) {
            let predicate = NSPredicate(format: "fireDate = %@ and setterId = %@", argumentArray: [alarm.fireDate, alarm.setterId])
            let query = PFQuery(className: "Alarm", predicate: predicate)
            let objects = query.findObjects() as! Array<PFObject>
            NSKeyedArchiver.archivedDataWithRootObject(alarm).writeToFile(alarmsPath.stringByAppendingPathComponent(objects.first!.objectId! + ".alf"), atomically: true)
        }
    }
}
