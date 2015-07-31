//
//  RecordViewController.swift
//  swaker
//
//  Created by William on 7/30/15.
//  Copyright (c) 2015 William. All rights reserved.
//


import UIKit
import Parse
import AVFoundation

class RecordViewController: UIViewController {
    
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var soundFileURL: NSURL!
    var channels = [String]()
    let MyuserDAO = UserDAO.sharedInstance()
    var alarm:Alarm!


    //MARK: recordStart
    @IBAction func recordStart(sender: AnyObject) {
        audioRecorder.record()
        
    }
    
    //MARK: recordEnd
    @IBAction func recordEnd(sender: AnyObject) {
        audioRecorder.stop()
    }

    //MARK: play
    @IBAction func play(sender: AnyObject) {
        var error:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: audioRecorder?.url,
            error: &error)
        audioPlayer.play()
    }
    
    
    //Mark viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        settingRecorder()
        //botao de push
        let butao = UIButton(frame: CGRectMake(200, 400, 100, 100))
        butao.setTitleColor(UIColor.blackColor(), forState: .Normal)
        butao.backgroundColor = UIColor.yellowColor()
        butao.setTitle("push me", forState: UIControlState.Normal)
        butao.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        self.view.addSubview(butao)
    }
    
    //MARK: acao do botao push
    func pressed(sender: UIButton!) {
        
        println("sending a push")
        
        var test = AudioDAO.sharedInstance()
        let Audiodata = NSData(contentsOfURL: self.soundFileURL!)
        var audioAttemp = AudioAttempt(alarmId: "novoTeste", audio: Audiodata, audioDescription: "minha record", senderId: "william")
        let AudioObject = test.addAudioAttempt(audioAttemp)
        let objectId = AudioObject?.objectId
        
        let data = [
            "a" : objectId!,
            //"category" : "PROPOSAL_CATEGORY",
            "alert" : "Push e muito loco",
            "badge" : "Increment",
            "sounds" : "cheering.caf"
        ]
        
        let comps = NSDateComponents()
        comps.year = 2016
        comps.month = 7
        comps.day = 29
        comps.hour = 3
        comps.minute = 10
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let date = gregorian!.dateFromComponents(comps);
        
        // Send push notification with expiration
        
        let push = PFPush()
        push.expireAtDate(date)
        push.setChannel("a" + alarm.objectId)
        push.setData(data)
        push.sendPushInBackground()
        
        
    }
    
    //MARK: coisas do recorder
    func settingRecorder() {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        var soundFilePath = docsDir.stringByAppendingPathComponent("Temporario")
        
        println("1:\(soundFilePath)")
        
        let manager = NSFileManager.defaultManager()
        if !manager.fileExistsAtPath(soundFilePath) {
            println("nao existe, cria")
            println("\(soundFilePath)")
            manager.createDirectoryAtPath(soundFilePath, withIntermediateDirectories: false, attributes: nil, error: nil)
        }
        else {
            println("exite temp")
        }
        soundFilePath = soundFilePath.stringByAppendingPathComponent("sound.caf")
        
        println("2:\(soundFilePath)")

        
        let recordSettings =
        [AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.00]
        
        var error: NSError?
        
        //Enviando para o banco o audio salvo em temp pelo recorder
        soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        

        
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord,
            error: &error)
        
        audioRecorder = AVAudioRecorder(URL: soundFileURL, settings: recordSettings as [NSObject : AnyObject], error: &error)
        audioRecorder.prepareToRecord()
        
        println("fim do setting recorder")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

