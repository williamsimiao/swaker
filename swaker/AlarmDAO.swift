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
    
    /***************************************************************************
        didSet: Verifica se a pasta existe e, caso ela não exista, cria-a.
    ***************************************************************************/
    var alarmsPath:String! {
        didSet {
            if !NSFileManager.defaultManager().fileExistsAtPath(self.alarmsPath) {
                var error:NSError?
                NSFileManager.defaultManager().createDirectoryAtPath(self.alarmsPath, withIntermediateDirectories: false, attributes: nil, error: &error)
                if error != nil {
                    println(error?.localizedDescription)
                }
            }
        }
    }
    
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
        let user = UserDAO.sharedInstance().currentUser!
        if user.friends != nil {
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
        let PFAlarm = alarm.toPFObject()

        if (PFAlarm.save()) {
            let predicate = NSPredicate(format: "fireDate = \(alarm.fireDate) and setterId = \(alarm.setterId)", argumentArray:nil)
            let query = PFQuery(className: "Alarm", predicate: predicate)
            let objects = query.findObjects() as! Array<PFObject>
            alarm.objectId = objects.first!.objectId
            let path = alarmsPath.stringByAppendingPathComponent("\(alarm.objectId!).alf")
            NSKeyedArchiver.archivedDataWithRootObject(alarm).writeToFile(path, atomically: true)
        }
    }
    
    /***************************************************************************
    Função que remove um alarme tanto do Parse quanto localmente
    Parâmetro: objectId deste alarme
    Retorno: sucesso ou não da operação
    ***************************************************************************/
    func deleteAlarm(objectId:String!) -> Bool {
        PFObject(withoutDataWithClassName: "Alarm", objectId: objectId).deleteEventually()
        var error:NSError?
        let path = alarmsPath.stringByAppendingPathComponent("\(objectId).alf")
        let success = NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
        if !success {
            println(error?.localizedDescription)
        }
        return success
    }
}
