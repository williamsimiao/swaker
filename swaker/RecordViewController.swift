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

protocol audioDataProtocol {
    func retornaAudio()-> NSData
}

class RecordViewController: UIViewController, AVAudioPlayerDelegate, AudioSelectionDelegate {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    var backgroundView: UIView!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var alarm:Alarm!
    var audioData: NSData!
    var myDelegate: audioDataProtocol? = nil
    var soundFilePath: String!
    var recordTimer: NSTimer!
    var playTimer: NSTimer!
    let delaytimeRecord = NSTimeInterval(0.2)
    let delaytimeLibrary = NSTimeInterval(0.6)
    
    var isRecordingNewAudio = false
    let manager = NSFileManager.defaultManager()
    
    enum categoriesIdentifiers:String{
        //notificacao de nova proposta de audio
        case proposal = "PROPOSAL_CATEGORY"
        //notificacao de amigo setou novo alarme, nao necessita de actions
        case newAlarm = "NEWALARM_CATEGORY"
        // nao precisa de category pra notification de audio aceito
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        sendButton.alpha = 0
        playButton.alpha = 0
        progressView.progress = 0
        progressView.tintColor = navBarTintColor
        sendButton.tintColor = navBarTintColor
        recordButton.setImage(UIImage(named: "gravando")!, forState: .Highlighted | .Selected)
        
        settingRecorder()
    }
    
    func setUpViews() {
        self.backgroundView = view
        self.backgroundView.frame = UIScreen.mainScreen().bounds
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.mainScreen().bounds
        gradientLayer.colors = mainColors
        gradientLayer.locations = mainLocations
        self.backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    //MARK: IBActions
    @IBAction func library(sender: AnyObject) {
        isRecordingNewAudio = false
    }
    
    @IBAction func recordStart(sender: AnyObject) {
        audioRecorder.record()
        progressView.progress = 0
        recordTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateRecordProgressView:", userInfo: nil, repeats: true)
    }
    
    @IBAction func recordEnd(sender: AnyObject) {
        isRecordingNewAudio = true
        audioRecorder.stop()
        recordTimer.invalidate()
        progressView.progress = 1
        UIView.animateWithDuration(delaytimeRecord, animations: { () -> Void in
            self.sendButton.alpha = 1
            self.playButton.alpha = 1
        })
        
        //SETANDO O AUDIO COMO O DA RECORD //
        audioData = NSData(contentsOfFile: soundFilePath)
    }
    
    @IBAction func play(sender: AnyObject) {
        var error: NSError?
        audioPlayer = AVAudioPlayer(data: audioData, error: &error)
        audioPlayer.delegate = self
        audioPlayer.play()
        playTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updatePlayProgressView:", userInfo: nil, repeats: true)
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        progressView.progress = 1
        playTimer.invalidate()
    }
    
    func updateRecordProgressView(sender: NSTimer) {
        println(progressView.progress)
        progressView.progress += Float(sender.timeInterval / 30)
    }
    
    func updatePlayProgressView(sender: NSTimer) {
        let total = audioPlayer.duration
        let currentTime = audioPlayer.currentTime
        println(Float(currentTime / total))
        if currentTime == total {
            sender.invalidate()
            println("tototot")
        }
        progressView.progress = Float(currentTime / total)
    }
    
    @IBAction func send(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: "Type a description for your audio.", preferredStyle: .Alert)
        var textField = UITextField()
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Description"
        }
        let action = UIAlertAction(title: "Send", style: .Default) { (action) -> Void in
            let theAttemp = self.sendPushOfAudioAttemptWithDescription((alert.textFields!.first as! UITextField).text)
            if self.isRecordingNewAudio == true {
                let audioSavedFromRecording = AudioSaved(myAudioAttempt: theAttemp)
                audioSavedFromRecording.saveAudioInToCreatedDir()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Destructive) { (cancel) -> Void in
        }
        alert.addAction(cancel)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: Push
    func sendPushOfAudioAttemptWithDescription(audioDescription: String!) -> AudioAttempt {
        
        //quando chegar aqui a propertie Audiodata deve ter sido setada ou em func controller, caso da library
        //ou em
        
        var audioAttemp = AudioAttempt(alarmId: alarm.objectId, audio: audioData, audioDescription: audioDescription, senderId: PFUser.currentUser()?.objectId)
        let AudioObject = AudioDAO.sharedInstance().addAudioAttempt(audioAttemp)
        let objectId = AudioObject?.objectId
        let data = [
            "category" : categoriesIdentifiers.proposal.rawValue,
            "alert" : "Proposta de áudio de \(UserDAO.sharedInstance().currentUser!.name)",
            "sounds" : "paidefamilia.mp3",
            "a" : objectId!
        ]
        let push = PFPush()
        push.expireAtDate(alarm.fireDate)
        push.setChannel("a" + alarm.objectId)
        push.setData(data)
        push.sendPushInBackground()
        
        return audioAttemp
    }
    
    
    //MARK: coisas do recorder
    func settingRecorder() {
        //lembrando que path sempre é o diretorio documents
        soundFilePath = AudioDAO.sharedInstance().path
        soundFilePath = soundFilePath.stringByAppendingPathComponent(alarm.objectId + ".caf")
        
        let recordSettings =
        [AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.00]
        var error: NSError?
        
        //Enviando para o banco o audio salvo em temp pelo recorder
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord,
            error: &error)
        audioRecorder = AVAudioRecorder(URL: soundFileURL, settings: recordSettings as [NSObject : AnyObject], error: &error)
        audioRecorder.prepareToRecord()
    }
    
    //MARK: prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AudioSelectionTableViewController" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let audioSelectionController = navigationController.topViewController as? AudioSelectionTableViewController
            if let viewController = audioSelectionController {
                viewController.myDelegate = self
            }
        }
    }
    
    /*
    Implementacacao do metodo do protocolo da AudioSelectionTableViewController
    Descricaao: atribui a propertie Audiodata o audio associado a cell selecionada na AudioSelectionTableViewController
    em seguida "dispenca" essa view
    */
    func controller(controller: AudioSelectionTableViewController, didSelectItem: NSData) {
        audioData = didSelectItem
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        UIView.animateWithDuration(delaytimeLibrary, animations: { () -> Void in
            self.sendButton.alpha = 1
            self.playButton.alpha = 1
        })
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

