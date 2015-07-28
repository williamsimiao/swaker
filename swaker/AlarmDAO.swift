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
    static var instance:AlarmDAO?
    
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
        Parâmetro: o alarme a ser salvo:Alarm
        Retorno: Void
    ***************************************************************************/
    func addAlarm(alarm:Alarm) -> Bool {
        if alarm.save() {
            let PFAlarm = alarm.toPFObject()
            PFAlarm.saveEventually({ (success, error) -> Void in
                let enumerator = NSFileManager.defaultManager().enumeratorAtPath(self.alarmsPath)
                while let alarmId:String = enumerator?.nextObject() as? String {
                    if alarmId == (alarm.objectId + ".alf") {
                        let path = self.alarmsPath.stringByAppendingPathComponent(alarm.objectId) + ".alf"
                        let toPath = self.alarmsPath.stringByAppendingPathComponent(PFAlarm.objectId!) + ".alf"
                        var error:NSError?
                        NSFileManager.defaultManager().moveItemAtPath(path, toPath: toPath, error: &error)
                    }
                }
            })
        }
        return false
    }
    
    /***************************************************************************
        Função que remove um alarme tanto do Parse quanto localmente
        Parâmetro: objectId deste alarme
        Retorno: sucesso ou não da operação
    ***************************************************************************/
    func deleteAlarm(objectId:String!) -> Bool {
        if Alarm.deleteAlarm(objectId) {
            PFObject(withoutDataWithClassName:"Alarm", objectId:objectId).deleteEventually()
            return true
        }
        return false
    }
}
