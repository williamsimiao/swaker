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

class RecordViewController: UIViewController, AudioSelectionDelegate {
    
    @IBOutlet weak var LibraryButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var PleaseLabel: UILabel!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var DescriptionField: UITextField!
    //record constrains
    @IBOutlet weak var recordHeigthConstrain: NSLayoutConstraint!
    @IBOutlet weak var recordWidthConstrain: NSLayoutConstraint!
    @IBOutlet weak var recordLeftConstrain: NSLayoutConstraint!
    //library constrains
    //so tem isso pq width e higth é igual ao do record
    @IBOutlet weak var libraryRigthContrain: NSLayoutConstraint!
    //play constrains
    @IBOutlet weak var playWidthConstrain: NSLayoutConstraint!
    @IBOutlet weak var playHigthConstrain: NSLayoutConstraint!
    //textField constrains
    @IBOutlet weak var textFieldBottomConstrain: NSLayoutConstraint!
    
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var alarm:Alarm!
    var Audiodata: NSData!
    var myDelegate: audioDataProtocol? = nil
    var soundFilePath: String!
    let delaytimeRecord = NSTimeInterval(0.2)
    let delaytimeLibrary = NSTimeInterval(0.6)
    
    //the variable below refers to whether the label that asks for the audio
    //description and the audio description textField should apper
    var isRecordingNewAudio: Bool!
    let manager = NSFileManager.defaultManager()
    
    enum categoriesIdentifiers:String{
        //notificacao de nova proposta de audio
        case proposal = "PROPOSAL_CATEGORY"
        //notificacao de amigo setou novo alarme, nao necessita de actions
        case newAlarm = "NEWALARM_CATEGORY"
        // nao precisa de category pra notification de audio aceito
    }
    
    
    
    //MARK: IBActions
    @IBAction func Library(sender: AnyObject) {
        isRecordingNewAudio = false
    }
    
    @IBAction func recordStart(sender: AnyObject) {
        audioRecorder.record()
        // vamos escode o botao da library
    }
    
    @IBAction func recordEnd(sender: AnyObject) {
        isRecordingNewAudio = true
        audioRecorder.stop()
        
        playButton.hidden = false
        PleaseLabel.hidden = false
        DescriptionField.hidden = false
        DescriptionField.hidden = false
        
        UIView.animateWithDuration(delaytimeRecord, animations: { () -> Void in
            self.SendButton.alpha = 1
            self.playButton.alpha = 1
            self.PleaseLabel.alpha = 1
            self.DescriptionField.alpha = 1
        })
        
        
        //SETANDO O AUDIO COMO O DA RECORD //
        Audiodata = NSData(contentsOfFile: soundFilePath)
    }
    
    @IBAction func play(sender: AnyObject) {
        var error = NSErrorPointer()
        audioPlayer = AVAudioPlayer(data: Audiodata, error: error)
        audioPlayer.play()
    }
    
    @IBAction func Send(sender: AnyObject) {
        let theAttemp = sendPushOfAudioAttempt()
        if isRecordingNewAudio == true {
            let audioSavedFromRecording = AudioSaved(myAudioAttempt: theAttemp)
            audioSavedFromRecording.SaveAudioInToCreatedDir()
        }
        
    }
    
    /*
        IBActio do textfild do tipo editing did end
    
    */
    
    @IBAction func didEditedDescription(sender: AnyObject) {
        //deveria fazer algumas validacoes
        if DescriptionField.text != " " && DescriptionField.text != "" {
            let error = NSErrorPointer()
            if manager.fileExistsAtPath(soundFilePath) {
                var pathWithNewName = soundFilePath.stringByAppendingPathComponent(DescriptionField.text)
                pathWithNewName  = pathWithNewName + ".caf"
                manager.moveItemAtPath(soundFilePath, toPath: pathWithNewName, error: error)
            }
        }
        SendButton.hidden = false
    }

    
    //MARK: view methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //constrains de distancia para a borda do recor e library, para os iphones
        recordLeftConstrain.constant = view.frame.width * 0.08
        libraryRigthContrain.constant = recordLeftConstrain.constant
        
        //constrains de altura e largura do botao record e consequente do botao library ja q eles tem constrain de igualdade de altura e latgura
        recordWidthConstrain.constant = (view.frame.width - 2*(recordLeftConstrain.constant)) / 2
        recordHeigthConstrain.constant = recordWidthConstrain.constant

        
        //constrains do play
        playHigthConstrain.constant = recordHeigthConstrain.constant * 0.3
        playWidthConstrain.constant = recordWidthConstrain.constant
        
        //please label internacionalization
        PleaseLabel.text = "intenaciolizacao"
        
        isRecordingNewAudio = false
        
        SendButton.hidden = true
        playButton.hidden = true
        PleaseLabel.hidden = true
        DescriptionField.hidden = true
        
        SendButton.alpha = 0
        playButton.alpha = 0
        PleaseLabel.alpha = 0
        DescriptionField.alpha = 0
        
        settingRecorder()
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    //MARK: Push
    func sendPushOfAudioAttempt() -> AudioAttempt {
        
        //quando chegar aqui a propertie Audiodata deve ter sido setada ou em func controller, caso da library
        //ou em
        
        var audioAttemp = AudioAttempt(alarmId: alarm.objectId, audio: self.Audiodata, audioDescription: DescriptionField.text, senderId: PFUser.currentUser()?.objectId)
        audioAttemp.audioName  = alarm.objectId
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
        
        println("Saving recor in: \(soundFilePath)")
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
        self.Audiodata = didSelectItem
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        playButton.hidden = false
        PleaseLabel.hidden = false
        DescriptionField.hidden = false
        DescriptionField.hidden = false
        
        UIView.animateWithDuration(delaytimeLibrary, animations: { () -> Void in
            self.SendButton.alpha = 1
            self.playButton.alpha = 1
            self.PleaseLabel.alpha = 1
            self.DescriptionField.alpha = 1
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

