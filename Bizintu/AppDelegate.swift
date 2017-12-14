//
//  AppDelegate.swift
//  Bizintu
//
//  Created by Austin Wei on 11/7/17.
//  Copyright © 2017 Bizintu. All rights reserved.
//

import GoogleMaps
import GooglePlaces
import UIKit
import Firebase
import GoogleSignIn
import FacebookCore
import FacebookLogin
import TwitterKit
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging
import MapKit
import EventKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var initialViewController: UIViewController?
    var ref: DatabaseReference!
    var storyboard: UIStoryboard!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyCOvstm02P2jkJEHwrOiroJiyx1_lQz3QA")
        GMSPlacesClient.provideAPIKey("AIzaSyCOvstm02P2jkJEHwrOiroJiyx1_lQz3QA")
        
        ref = Database.database().reference()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        Twitter.sharedInstance().start(withConsumerKey:"IpnR2aW8UjYC2wUKcQrXJaMcQ", consumerSecret:"R4l4UMUpQwINM0VWPvEaFnmJKrrzBoo5j4odnapJ6nvLk8pEEg")
        
        /*if (Auth.auth().currentUser != nil)
        {
            print("Logged on")
            let providerName = (Auth.auth().currentUser?.providerData)![0].providerID
            
            if (!(Auth.auth().currentUser?.isEmailVerified)! && providerName != "twitter.com" && providerName != "facebook.com")
            {
                initialViewController = storyboard.instantiateViewController(withIdentifier: "login")
            }
            else{
                initialViewController = storyboard.instantiateViewController(withIdentifier: "accountStart")
            }
        }
        else
        {
            initialViewController = storyboard.instantiateViewController(withIdentifier: "login")
        }*/
        
        return true
    }
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            let googleDidHandle = GIDSignIn.sharedInstance().handle(url,
                                                                    sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                                    annotation: [:])
            let facebookDidHandle = SDKApplicationDelegate.shared.application(application, open: url, options: options)
            let twitterDidHandle = Twitter.sharedInstance().application(application, open: url, options: options)
            return googleDidHandle || facebookDidHandle || twitterDidHandle
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

