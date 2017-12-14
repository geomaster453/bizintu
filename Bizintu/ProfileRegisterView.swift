//
//  ProfileRegisterView.swift
//  Bizintu
//
//  Created by Austin Wei on 12/14/17.
//  Copyright © 2017 Bizintu. All rights reserved.
//

import Foundation
import Firebase
import UIKit
import Photos

class ProfileRegisterView: UIViewController, URLSessionDataDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var profilePic: UIImageView!
    
    var providerName = ""
    var providerUserName = ""
    var providerPhotoURL: URL!
    
    var data : NSMutableData = NSMutableData()
    
    var alertController = UIAlertController()
    
    var firstName = ""
    var lastName = ""
    var password = ""
    var confirmed = ""
    var email = ""
    
    var responseString = "";
    
    var ref: DatabaseReference!
    var storageRef : StorageReference!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstNameField.delegate = self;
        self.lastNameField.delegate = self;
        picker.delegate = self;
        
        let userInfo = Auth.auth().currentUser?.providerData
        providerName = userInfo![0].providerID
        providerUserName = userInfo![0].displayName ?? ""
        providerPhotoURL = userInfo![0].photoURL
    }
    
    @IBAction func linkedUsername(_ sender: UIButton) {
        if (providerUserName != "")
        {
            let names = providerUserName.components(separatedBy: " ")
            firstNameField.text = names[0]
            if (names.count > 1)
            {
                var lastnametemp = ""
                for index in 1..<names.count {
                    if (index != 1)
                    {
                        lastnametemp += " "
                    }
                    lastnametemp += names[index]
                }
                lastNameField.text = lastnametemp
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.profilePic.image = UIImage(data: data)
            }
        }
    }
    
    @IBAction func linkedPhoto(_ sender: UIButton) {
        profilePic.contentMode = .scaleAspectFit
        if (providerPhotoURL != nil)
        {
            downloadImage(url: providerPhotoURL)
        }
    }
    
    
    
    @IBAction func shootPhoto(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker,animated: true,completion: nil)
        }
        else {
            noCamera()
        }
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    @IBAction func photoFromLibrary(_ sender: UIBarButtonItem) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.modalPresentationStyle = .overFullScreen
        present(picker, animated: true, completion: nil)
        picker.popoverPresentationController?.barButtonItem = sender
    }
    
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        profilePic.contentMode = .scaleAspectFit
        profilePic.image = chosenImage
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetProfilePic(_ sender: UIButton) {
        profilePic.image = #imageLiteral(resourceName: "PhotoPlaceholder.jpg")
    }
    
    @IBAction func registered(_ sender: UIButton) {
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference().child("ProfilePics")
        
        firstName = firstNameField.text!
        lastName = lastNameField.text!
        
        if (self.firstName == "")
        {
            self.alertController = UIAlertController(title: "No entered name.", message: "Please enter a first name (this will serve as a 'username')", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            }
            self.alertController.addAction(OKAction)
            
            OperationQueue.main.addOperation{
                self.present(self.alertController, animated: true) {
                    // ...
                }
            }
        }
        else
        {
            /*let storyboard = UIStoryboard(name: "MyStoryboardName", bundle: nil)
             let loadingcontroller = storyboard.instantiateViewController(withIdentifier: "someViewController")
             self.present(loadingcontroller, animated: true, completion: nil)*/
            
            self.ref.child("userdisplays/" + (Auth.auth().currentUser?.uid)! + "/firstname").setValue(self.firstName)
            self.ref.child("userprofiles/" + (Auth.auth().currentUser?.uid)! + "/fullname").setValue(self.firstName + " " + self.lastName)
            
            let profilePictureRef = self.storageRef.child((Auth.auth().currentUser?.uid)!)
            var data = NSData()
            data = UIImageJPEGRepresentation(self.profilePic.image!, 0.8)! as NSData
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            
            profilePictureRef.putData(data as Data, metadata: metadata){(metadata,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }else{
                    print("Got Photo")
                    //store downloadURL
                    let downloadURL = metadata!.downloadURL()!.absoluteString
                    //store downloadURL at database
                    self.ref.child("userdisplays/" + (Auth.auth().currentUser?.uid)! + "/userPhoto").setValue(downloadURL)
                    //try! Auth.auth().signOut()
                    self.performSegue(withIdentifier: "logIn", sender: self)
                }
            }
        }
    }
}


