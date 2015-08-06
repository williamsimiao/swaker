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
    
    @IBOutlet weak var PleaseLabel: UILabel!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var DescriptionField: UITextField!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var soundFileURL: NSURL!
    var channels = [String]()
    let MyuserDAO = UserDAO.sharedInstance()
    let MyaudioDAO = AudioDAO.sharedInstance()
    var alarm:Alarm!
    var audioToGo: NSData!
    
    enum categoriesIdentifiers:String{
        //notificacao de nova proposta de audio
        case proposal = "PROPOSAL_CATEGORY"
        //notificacao de amigo setou novo alarme, nao necessita de actions
        case newAlarm = "NEWALARM_CATEGORY"
        
        // nao precisa de category pra notification de audio aceito
    }
    
    @IBAction func Library(sender: AnyObject) {
        let audioLibrary = AudioLibraryTableViewController()
        SendButton.hidden = false
    }
    
    //MARK: recordStart
    @IBAction func recordStart(sender: AnyObject) {
        audioRecorder.record()
        
    }
    
    //MARK: recordEnd
    @IBAction func recordEnd(sender: AnyObject) {
        audioRecorder.stop()
        PleaseLabel.hidden = false
        DescriptionField.hidden = false
        SendButton.hidden = false
        
    }
    
    //MARK: play
    @IBAction func play(sender: AnyObject) {
        var error:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: audioRecorder?.url,
            error: &error)
        audioPlayer.play()
    }
    
    //MARK: acao do botao send
    @IBAction func Send(sender: AnyObject) {
        
        let Audiodata = NSData(contentsOfURL: self.soundFileURL!)
        var audioAttemp = AudioAttempt(alarmId: alarm.objectId, audio: Audiodata, audioDescription: DescriptionField.text, senderId: PFUser.currentUser()?.objectId)
        let AudioObject = MyaudioDAO.addAudioAttempt(audioAttemp)
        let objectId = AudioObject?.objectId
        let data = [
            "category" : categoriesIdentifiers.proposal.rawValue,
            "alert" : "Proposta de audio de \(MyuserDAO.currentUser!.name)",
            "sounds" : "paidefamilia.mp3",
            "a" : objectId!
        ]
        
        let push = PFPush()
        push.expireAtDate(alarm.fireDate)
        push.setChannel("a" + alarm.objectId)
        push.setData(data)
        push.sendPushInBackground()
    }
    
    //Mark viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        settingRecorder()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        SendButton.hidden = true
        DescriptionField.hidden = true
        PleaseLabel.hidden = true
    }
    
    //MARK: coisas do recorder
    func settingRecorder() {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        var soundFilePath = AudioDAO.sharedInstance().createdPath
        
        let manager = NSFileManager.defaultManager()
        if !manager.fileExistsAtPath(soundFilePath) {
            manager.createDirectoryAtPath(soundFilePath, withIntermediateDirectories: false, attributes: nil, error: nil)
        }
        soundFilePath = soundFilePath.stringByAppendingPathComponent(PleaseLabel.text! + "caf")
        
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
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AudioLibrarySegue" {
            let aLibrary = segue.destinationViewController as! AudioLibraryTableViewController
            aLibrary.allowAudioSelection = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

