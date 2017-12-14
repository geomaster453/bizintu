//
//  EmailRegisterView.swift
//  Bizintu
//
//  Created by Austin Wei on 12/14/17.
//  Copyright © 2017 Bizintu. All rights reserved.
//

import Foundation
import Firebase
import UIKit
import Photos

class EmailRegisterView: UIViewController, URLSessionDataDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    
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
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordField.delegate = self;
        self.confirmPassword.delegate = self;
        self.emailField.delegate = self;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    @IBAction func continueToProfile(_ sender: UIButton) {
        
        
        ref = Database.database().reference()
        
        password = passwordField.text!;
        confirmed = confirmPassword.text!;
        
        if (confirmed == password)
        {
            email = emailField.text!;
            
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        
                        
                        switch errCode {
                        case .invalidEmail:
                            self.alertController = UIAlertController(title: "The e-mail address you enterd is invalid.", message: "Please try again.", preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "OK", style: .default) { action in}
                            self.alertController.addAction(OKAction)
                        case .emailAlreadyInUse:
                            self.alertController = UIAlertController(title: "The e-mail address you entered is associated with another account.", message: "Please try again.", preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "OK", style: .default) { action in}
                            self.alertController.addAction(OKAction)
                        case .weakPassword:
                            self.alertController = UIAlertController(title: "Your password must be at least 6 characters long.", message: "Please try again.", preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "OK", style: .default) { action in}
                            self.alertController.addAction(OKAction)
                        default:
                            print("Create User Error: \(error!)")
                        }
                    }
                    
                } else {
                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                        // ...
                    }
                    self.alertController = UIAlertController(title: "An e-mail has been sent to the address you entered.", message: "Please follow instructions to verify your e-mail before signing in.", preferredStyle: .alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                        // ...
                        self.performSegue(withIdentifier: "continueToProfile", sender: self)
                        self.ref.child("userproviders/" + (Auth.auth().currentUser?.uid)!).setValue("Email")
                        
                        let devicetoken = InstanceID.instanceID().token()
                        self.ref.child("deviceusers/" + devicetoken! + "/" + (Auth.auth().currentUser?.uid)!).setValue(true)
                    }
                    self.alertController.addAction(OKAction)
                }
                OperationQueue.main.addOperation{
                    self.present(self.alertController, animated: true) {
                        // ...
                    }
                }
                // ...
            }
            
        }
        else{
            self.alertController = UIAlertController(title: "Incorrect confirmed password", message: "Please try again.", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { action in }
            self.alertController.addAction(OKAction)
            
            self.present(self.alertController, animated: true) {
                // ...
            }
            
        }
    }
}

