//
//  WelcomeController.swift
//  ShakeIt
//
//  Created by Denis Karpenko on 29.04.16.
//  Copyright © 2016 Denis Karpenko. All rights reserved.
//

import UIKit
import VideoSplashKit

class WelcomeController: VideoSplashViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("test", ofType: "mov")!)
        self.videoFrame = view.frame
        self.fillMode = .ResizeAspectFill
        self.alwaysRepeat = true
        self.sound = true
        self.startTime = 0.0
        self.duration = 18.5
        self.alpha = 0.9
        self.contentURL = url
        self.restartForeground = true

        // Do any additional setup after loading the view.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func Start(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "splash")
        self.dismissViewControllerAnimated(true, completion: {
            NSNotificationCenter.defaultCenter().postNotificationName("splash", object: nil)
        })
        
        //ADD SAVE
        
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
