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

class RecordViewController: UIViewController, AVAudioPlayerDelegate, UITextFieldDelegate {
    
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
    var currentCalendar = NSCalendar.currentCalendar()
    
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
        //Mudando o botao de send
        sendButton.backgroundColor = UIColor.clearColor()
        sendButton.layer.cornerRadius = 5
        sendButton.layer.borderWidth = 1
        sendButton.layer.borderColor = UIColor.blackColor().CGColor
        
        setUpViews()
        sendButton.alpha = 0
        playButton.alpha = 0
        progressView.progress = 0
        progressView.tintColor = navBarTintColor
        sendButton.tintColor = navBarTintColor
        recordButton.setImage(UIImage(named: "gravando")!, forState: .Highlighted | .Selected)
        settingRecorder()
    }
    
    override func viewWillAppear(animated: Bool) {
        if audioData != nil {
            var error: NSError?
            audioPlayer = AVAudioPlayer(data: audioData, error: &error)
            fadeButtonsIn()
        }
    }
    
    func setUpViews() {
        self.backgroundView = view
        self.backgroundView.frame = UIScreen.mainScreen().bounds
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.mainScreen().bounds
        let comps = currentCalendar.components(.CalendarUnitHour, fromDate: NSDate())
        let index = Int(round(Float(comps.hour == 0 ? 24 : comps.hour) / 3) - 1)
        gradientLayer.colors = mainColors[index]
        gradientLayer.locations = mainLocations[index] as! [AnyObject]
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
        fadeButtonsIn()
        
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
    
    func fadeButtonsIn() {
        UIView.animateWithDuration(delaytimeRecord, animations: { () -> Void in
            self.sendButton.alpha = 1
            self.playButton.alpha = 1
        })
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        progressView.progress = 1
        //playTimer.invalidate()
    }
    
    func updateRecordProgressView(sender: NSTimer) {
        println(progressView.progress)
        progressView.progress += Float(sender.timeInterval / 30)
    }
    
    func updatePlayProgressView(sender: NSTimer) {
        let total = audioPlayer.duration
        let currentTime = audioPlayer.currentTime
        if currentTime == total {
            sender.invalidate()
        }
        progressView.progress = Float(currentTime / total)
    }
    
    @IBAction func send(sender: AnyObject) {
        
        let alert = UIAlertController(title: nil, message: "Type a description for your audio.", preferredStyle: .Alert)
        var textField = UITextField()
        //actions
        let cancel = UIAlertAction(title: "Cancel", style: .Destructive) { (cancel) -> Void in
            //nothing?
        }
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Description"
        }
        
        let action = UIAlertAction(title: "Send", style: .Default) { (action) -> Void in
            let theAttemp = self.sendPushOfAudioAttemptWithDescription((alert.textFields!.first as! UITextField).text)
            if self.isRecordingNewAudio == true {
                let audioSavedFromRecording = AudioSaved(myAudioAttempt: theAttemp)
                audioSavedFromRecording.saveAudioInToCreatedDir()
            }
            self.navigationController?.popViewControllerAnimated(true)
            
        }
        alert.addAction(cancel)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    //MARK: Push
    func sendPushOfAudioAttemptWithDescription(audioDescription: String!) -> AudioAttempt {
        
        //quando chegar aqui a propertie Audiodata deve ter sido setada ou em func controller, caso da library
        //ou em
        
        let successAlert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
        
        var audioAttemp = AudioAttempt(alarmId: alarm.objectId, audio: audioData, audioDescription: audioDescription, senderId: PFUser.currentUser()?.objectId)
        let AudioObject = AudioDAO.sharedInstance().addAudioAttempt(audioAttemp)
        let objectId = AudioObject?.objectId
        let data = [
            "category" : categoriesIdentifiers.proposal.rawValue,
            "alert" : "New audio proposal from \(UserDAO.sharedInstance().currentUser!.name)",
            "badge" : "Increment",
            "sounds" : "propostaSound.caf",
            "a" : objectId!
        ]
        let push = PFPush()
        push.expireAtDate(alarm.fireDate)
        push.setChannel("a" + alarm.objectId)
        push.setData(data)
        push.sendPushInBackground()
        //self.navigationController?.popViewControllerAnimated(true)
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
        if segue.identifier == "audioSelection" {
            let navigationController = segue.destinationViewController as! UINavigationController
            if let audioSelectionController = navigationController.topViewController as? AudioSelectionViewController {
                audioSelectionController.recordingController = self
            }
        }
    }
    
    /*
        Implementacacao do metodo do protocolo da AudioSelectionTableViewController
        Descricaao: atribui a propertie Audiodata o audio associado a cell selecionada na AudioSelectionTableViewController
        em seguida "dispenca" essa view
        NAO FOI USADO
    */
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

