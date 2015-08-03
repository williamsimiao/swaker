
//  AppDelegate.swift
//  swaker
//
//  Created by William on 7/24/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

import Bolts
import Parse

// If you want to use any of the UI components, uncomment this line
// import ParseUI

// If you want to use Crash Reporting - uncomment this line
// import ParseCrashReporting

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //Identificadores para as categorias
    enum categoriesIdentifiers:String{
        //notificacao de nova proposta de audio
        case proposal = "PROPOSAL_CATEGORY"
        //notificacao de amigo setou novo alarme, nao necessita de actions
        case newAlarm = "NEWALARM_CATEGORY"
        
        // nao precisa de category pra notification de audio aceito
    }
    //Identificadores para as acoes de PROPOSAL_CATEGORY
    enum ActionsIdentifiers:String{
        //acao de aceitar o audio
        case accept = "ACCEPT_ACTION"
        //acao de recusar o audio
        case refuse = "REFUSE_ACTION"
    }

    
    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        //        Parse.enableLocalDatastore()
        
        // ****************************************************************************
        // Uncomment this line if you want to enable Crash Reporting
        // ParseCrashReporting.enable()
        //
        // Uncomment and fill in with your Parse credentials:
        Parse.setApplicationId("eKtqynNoZEzvVKyz1FF7c5P2AnZabIH2iFDxROlf", clientKey: "BWNFwG2GyaN9sWywej6Pzh5iyCYHedTOcJUyZ4oW")
        //
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        // PFFacebookUtils.initializeFacebook()
        // ****************************************************************************
        
        PFUser.enableAutomaticUser()
        
        let defaultACL = PFACL();
        
        // If you would like all objects to be private by default, remove this line.
        defaultACL.setPublicReadAccess(true)
        
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
        
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if application.respondsToSelector("registerUserNotificationSettings:") {
            // setting types
            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            
            /////////////CATEGORIES////////////
            //Setando action de aceitar audio
            let acceptAction = UIMutableUserNotificationAction()
            acceptAction.identifier = ActionsIdentifiers.accept.rawValue
            acceptAction.title = "Accept"
            acceptAction.activationMode = UIUserNotificationActivationMode.Background
            acceptAction.authenticationRequired = true
            acceptAction.destructive = false
            //Como o activationMode e foreground o autenticationRequeried e true
            
            //Setando action de recusar
            let refuseAction = UIMutableUserNotificationAction()
            refuseAction.identifier = ActionsIdentifiers.refuse.rawValue
            refuseAction.title = "Refuse"
            refuseAction.activationMode = UIUserNotificationActivationMode.Background
            refuseAction.authenticationRequired = true
            refuseAction.destructive = true
            //A action acima ja e destructive entao essa nao pode ser tambem, lose sera a de cor azul
            
            //Colocando as actions acima em categories
            //                let notificationCategory = notificationPayload["category"] as! UIMutableUserNotificationCategory
            let proposalCategory = UIMutableUserNotificationCategory()
            
            proposalCategory.identifier = categoriesIdentifiers.proposal.rawValue
            
            //actions para notification com a tela desbloqueada
            proposalCategory.setActions([acceptAction, refuseAction], forContext: UIUserNotificationActionContext.Default)
            
            //actions para notification na lockscreen
            proposalCategory.setActions([acceptAction, refuseAction], forContext: UIUserNotificationActionContext.Minimal)
            
            let categories = NSSet(objects: proposalCategory)
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: categories as Set<NSObject>)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let types = UIUserNotificationType.Badge | UIUserNotificationType.Alert | UIUserNotificationType.Sound
            
            application.registerForRemoteNotifications()
        }
        return true
    }
    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        
        PFPush.subscribeToChannelInBackground("") { (succeeded: Bool, error: NSError?) in
            if succeeded {
                println("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
            } else {
                println("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            println("Push notifications are not supported in the iOS Simulator.")
        } else {
            println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        PFPush.handlePush(userInfo)
//        if application.applicationState == UIApplicationState.Inactive {
//            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
//
//            }
//
//        }
//    }
    
    /*
        Metodo para receber notificacoes quando amigos setarem novo alarme
    */
    
    func getRecordViewController() {
        let tabController = self.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
        let navigation = tabController.viewControllers![3] as! UINavigationController
        
        let friendsAlarmsController = navigation.storyboard?.instantiateViewControllerWithIdentifier("FriendsAlarmsController") as! UITableViewController
        let recordController = friendsAlarmsController.storyboard?.instantiateViewControllerWithIdentifier("RecordController") as! UIViewController
        
        navigation.pushViewController(recordController, animated: true)
    }
    
    func getAlarmsViewController() {
        let tabController = self.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
        let navigation = tabController.viewControllers![3] as! UINavigationController
        
        let MyAlarmsController = navigation.storyboard?.instantiateViewControllerWithIdentifier("MyAlarmsController") as! UITableViewController
    }

    /*
    
    */
     func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        let notificationPayload = userInfo["aps"] as! NSDictionary
        
         if application.applicationState == UIApplicationState.Background {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            let notificationCategory = notificationPayload["category"] as! String
            if notificationPayload["category"] as! String == categoriesIdentifiers.newAlarm.rawValue {
                getAlarmsViewController()
                //application.applicationIconBadgeNumber = 0
            }
            if notificationPayload["category"] as! String == categoriesIdentifiers.proposal.rawValue {
                getRecordViewController()
            }

         }
        if application.applicationState == UIApplicationState.Active {
            let inAppNotification = UIAlertController()
            let message = notificationPayload["alert"] as! String
            if notificationPayload["category"] as! String == categoriesIdentifiers.newAlarm.rawValue {
                inAppNotification.title = "New alarm from\(message))"
            }
            if notificationPayload["category"] as! String == categoriesIdentifiers.proposal.rawValue {
                inAppNotification.title = "New alarm from\(message))"
            }
        }
     }
     
        
    
    func application(application: UIApplication,
        handleActionWithIdentifier identifier: String?,
        forRemoteNotification userInfo: [NSObject : AnyObject],
        completionHandler: () -> Void) {
            let notificationPayload = userInfo["aps"] as! NSDictionary
            
            // Create a pointer to the audio object
            let audio = userInfo["a"] as! String
            println("Buscando pelo audio de ID: \(audio)")
            if identifier == ActionsIdentifiers.accept.rawValue {
                if let audioObject = PFQuery(className: "AudioAttempt").whereKey("objectId", equalTo: audio).getFirstObject(){
                    println("achou")
                    let receivedAudio = AudioSaved(PFAudioSaved: audioObject)
                    receivedAudio.SaveAudioInToLibrary()
                    //just to be shure
                    println("audioDescription:\(receivedAudio.audioDescription!)")
                    
                }
                else {
                    println("nao achou")
                }
                
            }
            if identifier == ActionsIdentifiers.refuse.rawValue {
                //deletando o audio do audio attempt
                //AudioDAO.sharedInstance().deleteAudioAttempt(<#audioObject: PFObject#>)
                
            }

            completionHandler()
    }
    
    //--------------------------------------
    // MARK: Facebook SDK Integration
    //--------------------------------------
    
    ///////////////////////////////////////////////////////////
    // Uncomment this method if you are using Facebook
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    //     return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, session:PFFacebookUtils.session())
    // }
}
