//
//  AppDelegate.swift
//  ShakeIt
//
//  Created by Denis Karpenko on 14.02.16.
//  Copyright © 2016 Denis Karpenko. All rights reserved.
//

import UIKit




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]//!!
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        let defaults = NSUserDefaults.standardUserDefaults()
        if(defaults.boolForKey("splash")==false){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let logcontroller = storyboard.instantiateViewControllerWithIdentifier("Welcome")
        let view = logcontroller.view;
        self.window?.makeKeyAndVisible()
        delay(1.5){self.window?.rootViewController?.presentViewController(logcontroller, animated: false, completion: nil)
        }
        }
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("open", object: nil)
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }
    enum Shortcut: String {
        case insta = "shortInsta"
    }
    
    func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var quickActionHandled = false
        let type = shortcutItem.type.componentsSeparatedByString(".").last!
        if let shortcutType = Shortcut.init(rawValue: type) {
            switch shortcutType {
            case .insta:
                NSNotificationCenter.defaultCenter().postNotificationName("ShortInst", object: nil)
                quickActionHandled = true
            }
        }
        
        return quickActionHandled
    }


}

