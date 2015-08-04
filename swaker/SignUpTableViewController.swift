//
//  SignUpTableViewController.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 29/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class SignUpTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var indicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var senhaTextField: UITextField!
    @IBOutlet weak var senha2TextField: UITextField!
    @IBOutlet weak var nomeTextField: UITextField!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        navigationItem.titleView = indicator
        
        pictureImageView.layer.cornerRadius = pictureImageView.frame.height / 2
        pictureImageView.clipsToBounds = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    @IBAction func signUp(sender: AnyObject) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel) { (okAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (cancelAction) -> Void in
        }

        if (senhaTextField.text == senha2TextField.text) && (senha2TextField.text != "") && (senhaTextField.text != "") && (emailTextField.text != "") && (nomeTextField.text != "") {
            let indicator = self.indicator
            indicator.startAnimating()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                let user = User(username: self.emailTextField.text, password: self.senhaTextField.text, email: self.emailTextField.text, name: self.nomeTextField.text, photo: UIImagePNGRepresentation(self.pictureImageView.image))
                if UserDAO.sharedInstance().signup(user) {
                    alert.message = "Sign Up succeeded."
                    alert.addAction(okAction)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                } else {
                    alert.message = "Could not Sign Up."
                    alert.addAction(cancelAction)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.indicator.stopAnimating()
                })
            })
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pickAImage(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
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
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        pictureImageView.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
