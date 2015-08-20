//
//  RingViewController.swift
//  swaker
//
//  Created by William on 8/9/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class RingViewController: UIViewController, AVAudioPlayerDelegate {
    
    var backgroundView: UIView!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var alarm:Alarm!
    var audioToPlay: NSData!
    let manager = NSFileManager.defaultManager()
    var FireTimer: NSTimer!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor.blackColor()
        //setUpViews()
        
        
        
        SetUpNotification()//aqui acaha o alarme
        checkForAudioAttempt()


        // Do any additional setup after loading the view.
    }
    
    func playPraAcordar() {
        
        
        
        if audioToPlay != nil {
            println("Nao e null")
            var error: NSError?
            audioPlayer = AVAudioPlayer(data: audioToPlay, error: &error)
            audioPlayer.delegate = self
            AVAudioSession.sharedInstance().overrideOutputAudioPort(
                AVAudioSessionPortOverride.Speaker, error: nil)
            audioPlayer.play()
            let AcordaAlert = UIAlertController(title: "Time to Wake", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            let stopAction = UIAlertAction(title: "Stop", style: UIAlertActionStyle.Destructive, handler: { (AcordaAlert) -> Void in
                self.audioPlayer.pause()
            })
            AcordaAlert.addAction(stopAction)
            self.presentViewController(AcordaAlert, animated: true, completion: nil)
        }
        else {
            println("E null")
        }
    }
    
    /*
        Check if the file exists
    */
    
    func checkForAudioAttempt() {
        if alarm.audioId != nil {
            //sim, o nome do arquivo do audio é alarm.objectId
            let audioFileName = alarm.objectId! + ".caf"
            let path = AudioDAO.sharedInstance().temporaryPath.stringByAppendingPathComponent(audioFileName)
            println("path: \(path)")
            if manager.fileExistsAtPath(path) {
                audioToPlay = NSData(contentsOfFile: path)
                println("Arquivo achado")
            }
            else {
                println("arquivo nao achado")
            }
        }
        else {
            let alertController = UIAlertController(title: "Alarm without Audio", message: "Looks like no one send you an audio", preferredStyle: .Alert)

            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alertController) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
            alertController.addAction(okAction)

            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    func SetUpNotification() {
        if AlarmDAO.sharedInstance().userAlarms.count == 0 {
            println("O usuario nao possui alarmes")            
        }
        else {
            self.alarm = AlarmDAO.sharedInstance().nextAlarmTofire()
            println(self.alarm.fireDate)
            let Interval = alarm.fireDate.timeIntervalSinceNow - NSTimeInterval (NSTimeZone.systemTimeZone().secondsFromGMT )
            println(Interval)
            FireTimer = NSTimer.scheduledTimerWithTimeInterval(Interval, target: self, selector: "playPraAcordar", userInfo: nil, repeats: false)
            
        }
    }
    
    func setUpViews() {
        self.backgroundView = view
        self.backgroundView.frame = UIScreen.mainScreen().bounds
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.mainScreen().bounds
        gradientLayer.colors = mainColors
        gradientLayer.locations = mainLocations as [AnyObject]
        self.backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
