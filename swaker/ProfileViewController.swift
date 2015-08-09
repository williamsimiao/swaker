//
//  ProfileViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 09/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    var backgroundView: UIView!
    var alert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        instantiateAlertController()
        navigationItem.title = "Profile"
        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
        photoImageView.clipsToBounds = true
        if let photo = UserDAO.sharedInstance().currentUser!.photo {
            photoImageView.image = UIImage(data: photo)
        }
        nameTextField.text = UserDAO.sharedInstance().currentUser!.name
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
    
    func instantiateAlertController() {
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    }
    
    var hasShownAlert = false
    @IBAction func pickAImage(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        if !hasShownAlert {
            var cameraAction = UIAlertAction(title: "Take Photo", style: .Default) { (cameraAction) -> Void in
                if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                    imagePicker.sourceType = .Camera
                    self.presentViewController(imagePicker, animated: true, completion: nil)
                }
            }
            var libraryAction = UIAlertAction(title: "Choose from Camera Roll", style: .Default) { (libraryAction) -> Void in
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            var cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (cancelAction) -> Void in
                self.alert.dismissViewControllerAnimated(true, completion: nil)
            }
            alert.addAction(cameraAction)
            alert.addAction(libraryAction)
            alert.addAction(cancelAction)
            hasShownAlert = true
        }
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        photoImageView.image = image
        dismissViewControllerAnimated(true, completion: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "updateUser")
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "updateUser")
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func cancel() {
        nameTextField.resignFirstResponder()
        nameTextField.text = UserDAO.sharedInstance().currentUser!.name
        photoImageView.image = UIImage(data: UserDAO.sharedInstance().currentUser!.photo!)
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
    }
    
    func updateUser() {
        let user = UserDAO.sharedInstance().currentUser!
        user.photo = UIImagePNGRepresentation(photoImageView.image)
        user.name = nameTextField.text
        UserDAO.sharedInstance().updateUser(user)
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
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
