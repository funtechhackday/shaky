//
//  ViewController.swift
//  ShakeIt
//
//  Created by Denis Karpenko on 14.02.16.
//  Copyright © 2016 Denis Karpenko. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary



class ViewController: UIViewController,PhotoPickerDelegate,UIDocumentInteractionControllerDelegate {
    //pageView
    var frame: CGRect = CGRectMake(0, 0, 0, 0)
    
    var scrollView: UIScrollView?
    let imgCount  = 1
    //
    
    var LastImg:UIImage?
    @IBOutlet weak var shakePicture: SpringImageView!
    var picker:photoPicker?
    @IBOutlet weak var TipLabel: SpringLabel!
    var images: [UIImage] = []
    @IBOutlet weak var shakeAgain: SpringButton!
    var shake = false
    var scroolOnView = false
    var documentController: UIDocumentInteractionController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.becomeFirstResponder()
        self.picker = photoPicker()
        self.picker?.delegate = self
        //self.picker?.initializeSession()
        showLabel(2.0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification:", name:"open", object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification2:", name:"ShortInst", object: nil)
        
        
        
        //showPageView()
    }
    override func viewDidAppear(animated: Bool) {
        self.picker?.initializeSession()
        //debug
        //self.LastImg = UIImage(named: "ShakY2")!
        //self.imageTapped()
        //shareToInstagram()
        //startShakePhone()
    }
    override func viewWillAppear(animated: Bool) {
        startShakePhone()
    }
    
    @objc private func methodOfReceivedNotification(notification: NSNotification){
        startShakePhone()
    }
    @objc private func methodOfReceivedNotification2(notification: NSNotification){
        let instagramHooks = "instagram://tag?name=shakyapp"
        let instagramUrl = NSURL(string: instagramHooks)
        if UIApplication.sharedApplication().canOpenURL(instagramUrl!)
        {
            UIApplication.sharedApplication().openURL(instagramUrl!)
            
        } else {
            showAlert("You Have no Instagram:(".localized)
            //redirect to safari because the user doesn't have Instagram
            //UIApplication.sharedApplication().openURL(NSURL(string: "http://instagram.com/")!)
            //out message about intagram
        }
    }
    
    func shareToInstagram() {
        
        
            //let toSend = croppIngimage((LastImg)!,toRect: CGRect(x: 0, y: offset, width: LastImg!.size.width, height: LastImg!.size.width))
            let imageData = UIImageJPEGRepresentation(LastImg!, 100)
            let instagramURL = NSURL(string: "instagram://")
            let vkURL = NSURL(string: "vk://")
            let twitterURL = NSURL(string: "twitter://")
            let facebookURL = NSURL(string: "fbapi://")
            if (UIApplication.sharedApplication().canOpenURL(instagramURL!)||UIApplication.sharedApplication().canOpenURL(vkURL!)||UIApplication.sharedApplication().canOpenURL(twitterURL!)||UIApplication.sharedApplication().canOpenURL(facebookURL!)) {
            let captionString = "#shakyapp"
            let writePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("instagram.png")
            if imageData?.writeToFile(writePath, atomically: true) == false {
            
                return
            
            } else {

        
                let fileURL = NSURL(fileURLWithPath: writePath)
                
                self.documentController = UIDocumentInteractionController(URL: fileURL)
                
                self.documentController.delegate = self
                
                self.documentController.UTI = "com.instagram.photo"
                
                self.documentController.annotation = NSDictionary(object: captionString, forKey: "TwitterCaption")
                self.documentController.presentOpenInMenuFromRect(self.view.frame, inView: self.view, animated: true)
        }
        }
            else{
        self.showAlert("You Don't Have Twitter, Facebook,VK or Instagram")
        }
        
    }


    // shake Handler
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if(motion == UIEventSubtype.MotionShake && self.images.count<imgCount){
            self.shake = true
            self.images = []
            print("shake")
            delay(0.5){
                if(self.shake){
                self.picker?.CapturePhoto()
                }
            }
            
        }
    }
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if(motion == UIEventSubtype.MotionShake){
            self.shake = false
            print("Shake stopped")
            //self.picker!.CapturePhoto()
            if(self.images.count == imgCount){
            showPageView()
            }//else try harder
            else{
                self.images = []
                //showLabel(0.5)
                //TipLabel.text = "Shake harder!"
            }
            
        }

    }
    func updatePhoto() {
        if((self.picker?.lastPick) != nil){
        self.images.append(ModernizeImage((self.picker?.lastPick)!))
        }
        if (shake == true) && (self.images.count<imgCount){
            delay(0.9){
                self.picker?.CapturePhoto()
            }
        }
        else if(self.images.count == imgCount){
            showPageView()
        }
    }
    func startShakePhone(){
        self.shakePicture.stopAnimating()
        self.shakePicture.animation = "swing"
        self.shakePicture.duration = 1
        self.shakePicture.repeatCount = 1000000
        self.shakePicture.curve = "easeIn"
        self.shakePicture.animate()
    }
    func stopShakePhone(){
        self.shakePicture.stopAnimating()
    }
    func showLabel(del: CGFloat){
        self.TipLabel.animation = "slideUp"
        self.TipLabel.delay = del
        self.TipLabel.curve = "easeIn"
        self.TipLabel.duration = 1.0
        self.TipLabel.animate()
        self.TipLabel.hidden = false
        
        
    }
    func showPageView(){
        self.scrollView = nil
        LastImg = images[Int(0)]
        let mult = self.LastImg!.size.width/self.view.frame.size.width
        let offset = (self.view.frame.size.height - self.LastImg!.size.height/mult)/2
        let newframe = CGRect(x: self.view.frame.origin.x, y: offset, width:self.LastImg!.size.width/mult, height: self.LastImg!.size.height/mult)
        self.scrollView = UIScrollView(frame: newframe)
        print(images.count)
        if (scrollView != nil){
        for index in 0..<images.count {
            frame.origin.x = self.scrollView!.frame.size.width * CGFloat(index)
            frame.size = self.scrollView!.frame.size
            self.scrollView!.pagingEnabled = true
            
            //let subView = UIImageView(image:images[Int(index)])
            let subView = UIImageView(frame: frame)
            subView.image = images[Int(index)]
            //subView.backgroundColor = colors[inde
            self.scrollView!.addSubview(subView)
        }
        
        self.scrollView!.contentSize = CGSizeMake(self.scrollView!.frame.size.width * CGFloat(images.count), self.scrollView!.frame.size.height)
            self.view.addSubview(scrollView!)
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.bounces = false
        self.scroolOnView = true
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped"))
        self.scrollView?.userInteractionEnabled = true
        self.scrollView?.addGestureRecognizer(tapGestureRecognizer)
        self.images = []
    }
        
    }
    
    func imageTapped(){
        let alertController = UIAlertController(title: "Share Photos With Friends!".localized, message:"Don't Forget Our Hashtag #shakyapp".localized, preferredStyle: .Alert)
        let SocialNetworks = UIAlertAction(title: "Social Networks".localized, style: .Default) { (action) in
            self.shareToInstagram()
        }
        let SaveToGallery = UIAlertAction(title: "Save to Camera Roll".localized, style: .Default) { (action) in
            UIImageWriteToSavedPhotosAlbum(self.LastImg!, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
        let cncl = UIAlertAction(title: "Cancel".localized, style: .Cancel) { (action) in
            
        }

        alertController.addAction(SocialNetworks)
        alertController.addAction(SaveToGallery)
        alertController.addAction(cncl)
        self.presentViewController(alertController, animated: true) {
            // ...
        }
        //shareToOther()
        
    }
    @IBAction func instaPushed(sender: AnyObject) {
        let instagramHooks = "instagram://tag?name=shakyapp"
        let instagramUrl = NSURL(string: instagramHooks)
        if UIApplication.sharedApplication().canOpenURL(instagramUrl!)
        {
            UIApplication.sharedApplication().openURL(instagramUrl!)
            
        } else {
            showAlert("You Have no Instagram:(".localized)
            //redirect to safari because the user doesn't have Instagram
            //UIApplication.sharedApplication().openURL(NSURL(string: "http://instagram.com/")!)
            //out message about intagram
        }
    }
    
    func ModernizeImage(img:UIImage)->UIImage{
        let shak = UIImage(named: "ShakY2")!
        UIGraphicsBeginImageContext(img.size)
        img.drawInRect(CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height))
        shak.drawInRect(CGRect(x:img.size.width - 100 , y: img.size.height-350, width: 75, height: 180))// ofset from sides
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
        //return ResizeImage(result,targetSize: CGSizeMake(img.size.width, img.si)) // 1080 1080
    }
    func croppIngimage(imageToCrop:UIImage, toRect rect:CGRect) -> UIImage{
        let imageRef:CGImageRef = CGImageCreateWithImageInRect(imageToCrop.CGImage, rect)!
        let cropped:UIImage = UIImage(CGImage:imageRef)
        return cropped
    }
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func showAlert(message:String){
        let alertController = UIAlertController(title: "Attention!".localized, message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    
    func shareToOther(){
        print("share")
        let myShare = "#shakyapp"
        let image: UIImage = LastImg!
        let shareVC: UIActivityViewController = UIActivityViewController(activityItems: [(image), myShare], applicationActivities: nil)
        self.presentViewController(shareVC, animated: true, completion: nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved".localized, message: "Your Awesome Picture was Successfully Saved".localized, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Error!".localized, message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    
    
    
}

