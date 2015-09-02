//
//  SignUpViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 09/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var signUpButton: UIBarButtonItem!
    var indicator: UIActivityIndicatorView!
    var nomeTextField: UITextField!
    var emailTextField: UITextField!
    var email2TextField: UITextField!
    var senhaTextField: UITextField!
    var senha2TextField: UITextField!
    var pictureImageView: UIImageView!
    var editButton: UIButton!
    var backgroundView: UIView!
    var naviBackgroundView: UIView!
    var currentCalendar = NSCalendar.currentCalendar()
    var tableViewHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        navigationItem.titleView = indicator
        tableView.backgroundColor = UIColor.whiteColor()
        signUpButton.title = NSLocalizedString("Signup", comment: "Signup")
        setUpViews()
        let tapGR = UITapGestureRecognizer(target: self, action: Selector("backgroundTap:"))
        tableView.addGestureRecognizer(tapGR)
    }
    
    override func viewDidAppear(animated: Bool) {
        tableViewHeight = tableView.contentSize.height
    }
    
    func setUpViews() {
        tableView.alpha = 0.8
        tableView.tintColor = navBarTintColor
        self.backgroundView = view
        self.backgroundView.frame = UIScreen.mainScreen().bounds
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.mainScreen().bounds
        let comps = currentCalendar.components(.CalendarUnitHour, fromDate: NSDate())
        let index = Int(round(Float(comps.hour == 0 ? 24 : comps.hour) / 3) - 1)
        gradientLayer.colors = mainColor()
        gradientLayer.locations = mainLocation()
        self.backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        let naviBar = navigationController!.navigationBar
        naviBar.barStyle = UIBarStyle.Default
        naviBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        naviBar.shadowImage = UIImage()
        naviBackgroundView = UIView(frame: CGRect(x: 0, y: -20, width: naviBar.bounds.width, height: 20))
        naviBackgroundView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        naviBackgroundView.tag = 8001
        naviBar.addSubview(naviBackgroundView)
        naviBar.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        naviBar.tintColor = navBarTintColor
        naviBar.titleTextAttributes = [NSForegroundColorAttributeName: navBarTintColor]
        
        let separator = UIView(frame: CGRect(x: 0, y: naviBar.frame.height, width: naviBar.frame.width, height: 0.5))
        separator.backgroundColor = separatorColor
        naviBar.addSubview(separator)
    }
    
    @IBAction func signUp(sender: AnyObject) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel) { (okAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (cancelAction) -> Void in
        }
        
        if (senhaTextField.text == senha2TextField.text) && (emailTextField.text == email2TextField.text) && (senha2TextField.text != "") && (senhaTextField.text != "") && (emailTextField.text != "") && (nomeTextField.text != "") {
            let indicator = self.indicator
            indicator.startAnimating()
            var image: UIImage!
            if pictureImageView != nil {
                image = pictureImageView.image
            } else {
                image = UIImage(named: "userDefault.png")
            }
            if let img = image {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    let user = User(username: self.emailTextField.text, password: self.senhaTextField.text, email: self.emailTextField.text, name: self.nomeTextField.text, photo: UIImagePNGRepresentation(self.pictureImageView.image))
                    let signUpResult = UserDAO.sharedInstance().signup(user)
                    if signUpResult.success {
                        alert.message = "Sign Up succeeded."
                        alert.addAction(okAction)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                    } else {
                        let userInfo = signUpResult.error!.userInfo as! [String:AnyObject]
                        if userInfo["code"] as! Int == 202 {
                            alert.title = NSLocalizedString("CouldntSignup", comment: "CouldntSignup")
                            alert.message = NSLocalizedString("UsernameTaken", comment: "CouldntSignup")
                            alert.addAction(cancelAction)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.presentViewController(alert, animated: true, completion: nil)
                            })
                        } else {
                            alert.message = NSLocalizedString("CouldntSignup", comment: "CouldntSignup")
                            alert.addAction(cancelAction)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.presentViewController(alert, animated: true, completion: nil)
                            })
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.indicator.stopAnimating()
                    })
                })
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pickAnImage(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        var cameraAction = UIAlertAction(title: NSLocalizedString("TakePhoto", comment: "Take Photo"), style: .Default) { (cameraAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                imagePicker.sourceType = .Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }
        var libraryAction = UIAlertAction(title: NSLocalizedString("CameraRoll", comment: "Camera Roll"), style: .Default) { (libraryAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }
        var cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Cancel) { (cancelAction) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender as! UIView
            popoverController.sourceRect = sender.bounds
        }
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        pictureImageView.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
            let cell = cell as! TextFieldCell
            nomeTextField = cell.textField
            nomeTextField.placeholder = NSLocalizedString("Name", comment: "Name")
            nomeTextField.delegate = self
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
            let cell = cell as! TextFieldCell
            emailTextField = cell.textField
            emailTextField.placeholder = NSLocalizedString("Email", comment: "Email")
            emailTextField.delegate = self
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
            let cell = cell as! TextFieldCell
            email2TextField = cell.textField
            email2TextField.placeholder = NSLocalizedString("ConfirmEmail", comment: "Confirm Email")
            email2TextField.delegate = self
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
            let cell = cell as! TextFieldCell
            senhaTextField = cell.textField
            senhaTextField.placeholder = NSLocalizedString("Password", comment: "Password")
            senhaTextField.delegate = self
        case 4:
            cell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
            let cell = cell as! TextFieldCell
            senha2TextField = cell.textField
            senha2TextField.placeholder = NSLocalizedString("ConfirmPassword", comment: "ConfirmPassword")
            senha2TextField.delegate = self
        case 5:
            cell = tableView.dequeueReusableCellWithIdentifier("imageViewCell") as! ImageViewCell
            let cell = cell as! ImageViewCell
            editButton = cell.editButton
            editButton.addTarget(self, action: "pickAnImage:", forControlEvents: UIControlEvents.TouchUpInside)
            editButton.setTitle(NSLocalizedString("Edit", comment: "Edit"), forState: .Normal)
            pictureImageView = cell.theImageView
            pictureImageView.layer.cornerRadius = pictureImageView.frame.height / 2
            pictureImageView.clipsToBounds = true
        default:
            break
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 5 {
            return 140
        }
        return 44
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String!
        switch section {
        case 0:
            title = NSLocalizedString("Name", comment: "Name")
        case 1:
            title = NSLocalizedString("Email", comment: "Email")
        case 2:
            title = NSLocalizedString("ConfirmEmail" , comment: "Confirm Email")
        case 3:
            title = NSLocalizedString("Password", comment: "Password")
        case 4:
            title = NSLocalizedString("ConfirmPassword", comment: "ConfirmPassword")
        case 5:
            title = NSLocalizedString("Photo", comment: "Photo")
        default:
            title = ""
        }
        return title
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = navBarTintColor
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        tableView.contentSize = CGSize(width: tableView.frame.width, height: tableView.frame.height + 320)
    }
    
    func dismissKeyboard() {
        nomeTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        email2TextField.resignFirstResponder()
        senha2TextField.resignFirstResponder()
        senhaTextField.resignFirstResponder()
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.tableView.contentSize = CGSize(width: self.tableView.frame.width, height: self.tableViewHeight)
        })
        
    }
    
    func backgroundTap(sender: AnyObject) {
        dismissKeyboard()
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
