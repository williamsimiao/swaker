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
    
/*//////////////////////////////CLASS ATTS AND FUNCTIONS\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
    //MARK: Class atts and functions
    static let friendsAlarmsUpdated = "friendsAlarmsUpdated"
    static var instance:AlarmDAO?
    static func sharedInstance() -> AlarmDAO {
        if instance == nil {
            instance = AlarmDAO()
            let docs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
            instance?.alarmsPath = docs.stringByAppendingPathComponent("Alarms")
            instance?.idsPath = docs.stringByAppendingPathComponent("userAlarmsIdsToDelete.plist")
            if let idsToDelete = NSKeyedUnarchiver.unarchiveObjectWithFile(instance!.idsPath) as? [String] {
                instance?.userAlarmsIdsToDelete = idsToDelete
            }
            println(instance?.alarmsPath)
        }
        return instance!
    }
    
    static func unload() {
        if instance != nil {
            self.instance = nil
        }
    }
    
    /*//////////////////////////////INSTANCE ATTS AND FUNCTIONS\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
    
    //MARK: Properties
    var friendsAlarmsDelegate: AlarmDAODataUpdating?
    
    //MARK: Paths
    let docs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
    var idsPath:String!
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
    
    //MARK: Alarms properties
    var userAlarmsIdsToDelete = [String]()
    var userAlarms = [Alarm]()
    var friendsAlarms = [Alarm]() {
        didSet {
            if friendsAlarmsDelegate != nil {
                friendsAlarmsDelegate!.reloadData()
            }
        }
    }
    
    //MARK: Functions
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
                    if (Int(anAlarm.fireDate.timeIntervalSinceNow) - NSTimeZone.localTimeZone().secondsFromGMT) > 0 {
                        userAlarms.append(anAlarm)
                    } else {
                        // Move os audios ja tocados pra pasta certa
                        self.deleteAlarm(anAlarm)
                    }
                }
            }
        }
    }
    
    /***************************************************************************
        Função que remove os alarmes do Parse caso não existam localmente.
        Parâmetro: Void
        Retorno: Void
    ***************************************************************************/
    func deleteCloudAlarmsIfNeeded() {
        var ids = [String]()
        for alarm in userAlarms {
            ids.append(alarm.objectId)
        }
        let query = PFQuery(className: "Alarm").whereKey("setterId", equalTo: UserDAO.sharedInstance().currentUser!.objectId).whereKey("objectId", notContainedIn: ids)
        query.findObjectsInBackgroundWithBlock { (alarms, error) -> Void in
            if error == nil {
                let alarms = alarms as! [PFObject]
                for alarm in alarms {
                    alarm.delete()
                }
            }
        }
        deletePendingAlarms()
    }
    
    func deletePendingAlarms() {
        var error:NSError?
        var success:Bool!
        for alarmId in userAlarmsIdsToDelete {
            PFObject(withoutDataWithClassName: "Alarm", objectId: alarmId).deleteInBackgroundWithBlock({ (success, error) -> Void in
                if !success {
                    let info = error!.userInfo as! [String:AnyObject]
                    let code = info["code"] as! Int
                    if code == 101 {
                        let index = find(self.userAlarmsIdsToDelete, alarmId)!
                        self.userAlarmsIdsToDelete.removeAtIndex(index)
                    }
                }
                NSKeyedArchiver.archiveRootObject(self.userAlarmsIdsToDelete, toFile: self.idsPath)
            })
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
        
        let user = UserDAO.sharedInstance().currentUser!
        var ids = [String]()
        for friend in user.friends {
            ids.append(friend.objectId)
        }
        let query = PFQuery(className: "Alarm").whereKey("setterId", containedIn: ids)
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        query.findObjectsInBackgroundWithBlock({ (alarms, error) -> Void in
            if error == nil {
                var fAlarms = [Alarm]()
                let alarms = alarms as! [PFObject]
                for alarm in alarms {
                    fAlarms.append(Alarm(PFAlarm: alarm))
                }
                self.friendsAlarms = fAlarms
            }
        })
    }
    
    /***************************************************************************
        Função que adiciona um novo alarme
        Parâmetro: o alarme a ser salvo: Alarm
        Retorno: Void
    ***************************************************************************/
    func addAlarm(alarm:Alarm) -> Bool {
        let PFAlarm = alarm.toPFObject()
        if PFAlarm.save() {
            alarm.objectId = PFAlarm.objectId
            alarm.save()
            PFInstallation.currentInstallation().addObject("a"+alarm.objectId, forKey: "channels")
            PFInstallation.currentInstallation().save()
            alarm.schedule()
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
        if alarm.delete() {
            userAlarmsIdsToDelete.append(alarm.objectId)
            deletePendingAlarms()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                if let objects = PFQuery(className: "AudioAttempt").whereKey("alarmId", equalTo: alarm.objectId).findObjects() {
                    for obj in objects {
                        (obj as! PFObject).deleteEventually()
                    }
                }
            })
            NSKeyedArchiver.archiveRootObject(userAlarmsIdsToDelete, toFile: idsPath)
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
}

//MARK: Data Updating Protocol
protocol AlarmDAODataUpdating {
    func reloadData()
}
