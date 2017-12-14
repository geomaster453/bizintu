//
//  RegisterMenuController.swift
//  Lifergy
//
//  Created by Austin Wei on 7/23/17.
//  Copyright © 2017 Austin Wei. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FacebookCore
import FacebookLogin
import TwitterKit

class RegisterMenuController: UITableViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    weak var delegate: SegueHandler?
    
    var window: UIWindow?
    
    var ref: DatabaseReference!

    @IBAction func googleSignUp(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }

    @IBAction func facebookSignUp(_ sender: UIButton) {
        AccessToken.current = nil
        UserProfile.current = nil
        let fbLoginManager = LoginManager()
        fbLoginManager.logOut()
        //fbLoginManager.loginBehavior = LoginBehavior.web
        fbLoginManager.logIn(readPermissions: [ ReadPermission.publicProfile ], viewController: self) { loginResult in
            
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                
                self.verifyAndSignIn(provider: "Facebook", credential: credential)
            }
        }
    }

    @IBAction func signUpWithTwitter(_ sender: UIButton) {
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                let credential = TwitterAuthProvider.credential(withToken: (session?.authToken)!, secret: (session?.authTokenSecret)!)
                self.verifyAndSignIn(provider: "Twitter", credential: credential)
                
            } else {
                print("error: \(error?.localizedDescription)");
            }
        })
    }
    
    
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        
        GIDSignIn.sharedInstance().signOut()
        if let error = error {
            // ...
            print(error.localizedDescription)
            
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        verifyAndSignIn(provider: "Google", credential: credential)
    }
    
    func verifyAndSignIn(provider: String, credential: AuthCredential)
    {
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                // ...
                print(error.localizedDescription)
            }
            
            self.ref.child("userproviders").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.hasChild((Auth.auth().currentUser?.uid)!){
                    let alertController = UIAlertController(title: "Old Account", message: "A Lifergy account is already associated with these " + provider + " credentials.", preferredStyle: .alert)
                    let signInAction = UIAlertAction(title: "Sign in to existing account.", style: .default) { action in
                        
                        self.window = UIWindow(frame: UIScreen.main.bounds)
                        self.window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "accountStart")
                        self.window?.makeKeyAndVisible()
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                        try! Auth.auth().signOut()
                        GIDSignIn.sharedInstance().signIn()
                    }
                    alertController.addAction(signInAction)
                    alertController.addAction(cancelAction)
                    OperationQueue.main.addOperation{
                        self.present(alertController, animated: true) {
                            // ...
                        }
                    }
                } else{
                    self.ref.child("userproviders/" + (Auth.auth().currentUser?.uid)!).setValue(provider)
                    
                    let devicetoken = InstanceID.instanceID().token()
                    self.ref.child("deviceusers/" + devicetoken! + "/" + (Auth.auth().currentUser?.uid)!).setValue(true)
                    self.continueToProfile()
                }
            })
            // User is signed in
            // ...
        }
        
    }
    
    func continueToProfile()
    {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = storyboard?.instantiateViewController(withIdentifier: "profileRegisterView")
        self.window?.makeKeyAndVisible()
        /*let profileRegister = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileRegisterView") as! ProfileRegisterView
         OperationQueue.main.addOperation{
         self.present(profileRegister, animated: true, completion: nil)
         }*/
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view is GIDSignInButton {
            return false
        }
        return true
    }
    
}

