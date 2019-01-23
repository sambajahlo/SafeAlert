//
//  AppDelegate.swift
//  SafeAlert
//
//  Created by Samba Diallo on 1/15/19.
//  Copyright © 2019 Samba Diallo. All rights reserved.
//

import UIKit
import Parse
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    //MARK: Properties
    var window: UIWindow?

    
    //MARK: Application lifecycle functions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize Parse
        // Set applicationId and server based on the values in the Heroku settings.
        Parse.initialize(
            with: ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) -> Void in
                configuration.applicationId = "safealert"
                configuration.clientKey = "fdafewfewqgwqgergqwjir34l23jk423lk4"  // set to nil assuming you have not set clientKey
                configuration.server = "https://safe-alert-app.herokuapp.com/parse"
            })
        )
        
        // check if user is logged in.
        if PFUser.current() != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //skips the login view controller to the main
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "mainVC")
        }

        

        return true
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

