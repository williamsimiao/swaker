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
            instance?.loadFriendsAlarms()
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
        userAlarms.removeAll(keepCapacity: false)
        let enumerator = NSFileManager.defaultManager().enumeratorAtPath(self.alarmsPath)
        while let alarm:String = enumerator?.nextObject() as? String{
            if alarm.hasSuffix("alf") {
                let filePath = alarmsPath.stringByAppendingPathComponent(alarm)
                let data = NSData(contentsOfFile: filePath)
                var anAlarm = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! Alarm
                if anAlarm.setterId == UserDAO.sharedInstance().currentUser?.objectId {
                    userAlarms.append(anAlarm)
                }
            }
        }
    }
    
    /***************************************************************************
        Função que remove os alarmes do Parse caso não existam localmente.
        Devolve um array de alarmes para a propriedade self.userAlarms
        Parâmetro: Void
        Retorno: Void
    ***************************************************************************/
    func deleteLocalAlarmsIfNeeded() {
        let query = PFQuery(className: "Alarm").whereKey("setterId", equalTo: UserDAO.sharedInstance().currentUser!.objectId)
        if let alarms = query.findObjects() as? [PFObject] {
            var exists = false
            for alarm in alarms {
                for lAlarm in userAlarms {
                    if alarm.objectId == lAlarm.objectId {
                        exists = true
                        break
                    }
                }
                if !exists {
                    alarm.deleteEventually()
                }
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
        self.friendsAlarms.removeAll(keepCapacity: false)
        var fAlarms = [Alarm]()
        let bigQuery = PFQuery(className: "Alarm")
        let user = UserDAO.sharedInstance().currentUser!
        if user.friends != nil {
            for friend in user.friends! {
                let query = bigQuery.whereKey("setterId", equalTo: friend.objectId)
                let alarms = query.findObjects() as? Array<PFObject>
                if alarms != nil {
                    for alarm in alarms! {
                        fAlarms.append(Alarm(PFAlarm: alarm))
                    }
                }
            }
        }
        self.friendsAlarms = fAlarms
    }
    
    /***************************************************************************
        Função que adiciona um novo alarme
        Parâmetro: o alarme a ser salvo:Alarm
        Retorno: Void
    ***************************************************************************/
    func addAlarm(alarm:Alarm) -> Bool {
        let PFAlarm = alarm.toPFObject()
        if PFAlarm.save() {
            let enumerator = NSFileManager.defaultManager().enumeratorAtPath(self.alarmsPath)
            while let alarmId:String = enumerator?.nextObject() as? String {
                if alarmId == (alarm.objectId + ".alf") {
                    let path = self.alarmsPath.stringByAppendingPathComponent(alarm.objectId) + ".alf"
                    let toPath = self.alarmsPath.stringByAppendingPathComponent(PFAlarm.objectId!) + ".alf"
                    var error:NSError?
                    var alarm = NSKeyedUnarchiver.unarchiveObjectWithData(NSData(contentsOfFile: path)!) as! Alarm
                    alarm.objectId = PFAlarm.objectId
                    alarm.save()
                    NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
                    PFInstallation.currentInstallation().addObject("a"+alarm.objectId, forKey: "channels")
                    PFInstallation.currentInstallation().save()
                }
            }
            return true
        }
        return false
    }
    
    /***************************************************************************
        Função que remove um alarme tanto do Parse quanto localmente
        Parâmetro: Alarme a ser removido
        Retorno: sucesso ou não da operação
    ***************************************************************************/
    func deleteAlarm(alarm:Alarm!) -> Bool {
        if Alarm.deleteAlarm(alarm) {
            PFObject(withoutDataWithClassName:"Alarm", objectId:alarm.objectId).deleteEventually()
//            PFPush.unsubscribeFromChannelInBackground("a"+alarm.objectId)
            let installation = PFInstallation.currentInstallation()
            installation.removeObject("a"+alarm.objectId, forKey: "channels")
            installation.save()
            if let objects = PFQuery(className: "AudioAttempt").whereKey("alarmId", equalTo: alarm.objectId).findObjects() {
                for obj in objects {
                    (obj as! PFObject).deleteEventually()
                }
            }
            return true
        }
        return false
    }
    
    
    /***************************************************************************
        Função que adiciona assinaturas aos canais correspondentes aos alarmes do usuário
        Parâmetro: void
        Retorno: void
    ***************************************************************************/
    func subscribeToAlarms() {
        for alarm in userAlarms {
            PFInstallation.currentInstallation().addObject("a"+alarm.objectId, forKey: "channels")
        }
        PFInstallation.currentInstallation().save()
    }
    
    static func unload() {
        if instance != nil {
            self.instance = nil
        }
    }
}
