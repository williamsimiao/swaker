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

class RingViewController: UIViewController {
    
    var backgroundView: UIView!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var alarm:Alarm!
    var audioToPlay: NSData!
    let manager = NSFileManager.defaultManager()
    var FireTimer: NSTimer!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setUpViews()
        SetUpNotification()//aqui acaha o alarme
        checkForAudioAttempt()


        // Do any additional setup after loading the view.
    }
    
    func playPraAcordar() {
        if audioToPlay != nil {
            let error = NSErrorPointer()
            audioPlayer = AVAudioPlayer(data: audioToPlay, error: error)
        }
    }
    
    /*
        Check if the file exists
    */
    
    func checkForAudioAttempt() {
        if alarm.audioId != nil {
            let audioFileName = alarm.audioId! + ".caf"
            let path = AudioDAO.sharedInstance().receivedPath.stringByAppendingPathComponent(audioFileName)
            if manager.fileExistsAtPath(path) {
                audioToPlay = NSData(contentsOfFile: path)
                println("Arquivo achado")
            }
        }
        else {
            let alertController = UIAlertController(title: "Alarm without Audio", message: "Looks like no one send you an audio", preferredStyle: .Alert)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    func SetUpNotification() {
        if AlarmDAO.sharedInstance().userAlarms.count == 0 {
            println("O usuario nao possui alarmes")            
        }
        else {
            self.alarm = AlarmDAO.sharedInstance().nextAlarmTofire()
            let Interval = alarm.fireDate.timeIntervalSinceNow
            FireTimer = NSTimer.scheduledTimerWithTimeInterval(Interval, target: self, selector: "playPraAcordar", userInfo: nil, repeats: true)
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
