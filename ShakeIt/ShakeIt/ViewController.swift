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
import Photos
import PhotosUI
import MobileCoreServices
import AudioToolbox


struct FilePaths {
    static let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.CachesDirectory,.UserDomainMask,true)[0]
    struct VidToLive {
        static var livePath = FilePaths.documentsPath.stringByAppendingString("/")
    }
}


class ViewController: UIViewController,PhotoPickerDelegate,VideoPickerDelegate,UIDocumentInteractionControllerDelegate {
    //pageView
    var frame: CGRect = CGRectMake(0, 0, 0, 0)
    
    var scrollView: UIScrollView?
    var livePhotoView: PHLivePhotoView?
    let imgCount  = 1
    //
    var recording = false;
    var LastImg:UIImage?
    @IBOutlet weak var shakePicture: SpringImageView!
    var picker:photoPicker?
    var videoPicker:videPicker?
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
        //self.picker = photoPicker()
        //self.picker?.delegate = self
        self.videoPicker = videPicker()
        self.videoPicker?.delegate = self
        //self.picker?.initializeSession()
        showLabel(2.0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification:", name:"open", object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification2:", name:"ShortInst", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification3:", name:"splash", object: nil)
        
        
        
        //showPageView()
    }
    override func viewDidAppear(animated: Bool) {
        //self.picker?.initializeSession()
        let defaults = NSUserDefaults.standardUserDefaults()
        if(defaults.boolForKey("splash")==true){
        self.videoPicker!.config()
        }
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
    @objc private func methodOfReceivedNotification3(notification: NSNotification){
        self.videoPicker!.config()
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
            let imageData = NSData(contentsOfFile: FilePaths.VidToLive.livePath.stringByAppendingString("/IMG.JPG"))
            //let imageData = UIImageJPEGRepresentation(LastImg!, 100)
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
//        if(motion == UIEventSubtype.MotionShake && self.images.count<imgCount){
//            self.shake = true
//            self.images = []
//            print("shake")
//            delay(0.5){
//                if(self.shake){
//                self.picker?.CapturePhoto()
//                }
//            }
//            
//        }
        if(motion == UIEventSubtype.MotionShake && AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Authorized){
            if(self.shake==false){
            print("shake started")
            videoPicker?.makeVideo()
            self.recording = true
            self.shake = true
            }
        }
    }
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
//        if(motion == UIEventSubtype.MotionShake){
//            self.shake = false
//            print("Shake stopped")
//            //self.picker!.CapturePhoto()
//            if(self.images.count == imgCount){
//            showPageView()
//            }//else try harder
//            else{
//                self.images = []
//                //showLabel(0.5)
//                //TipLabel.text = "Shake harder!"
//            }
//            
//        }
        if(motion == UIEventSubtype.MotionShake){
            self.shake = false
            print("Shake stopped")
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
    func updateVideo() {
        if(self.shake){
        self.showLivePhoto()
        }// else print error
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
    
    func showLivePhoto(){
        //let mult = self.LastImg!.size.width/self.view.frame.size.width
        
        let offset = self.view.frame.size.height*0.125
        let newframe = CGRect(x: 0, y: offset, width: self.view.frame.width, height: self.view.frame.height*0.75)
        self.livePhotoView = PHLivePhotoView(frame: newframe)
        //loadVideoWithVideoURL(NSBundle.mainBundle().URLForResource("video", withExtension: "m4v")!)
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("liveTapped"))
        self.livePhotoView?.userInteractionEnabled = true
        self.livePhotoView?.addGestureRecognizer(tapGestureRecognizer)
        
        loadVideoWithVideoURL((videoPicker?.link)!)
        self.view.addSubview(livePhotoView!)
        
    }
    
    func liveTapped(){
        let alertController = UIAlertController(title: "Share Photos With Friends!".localized, message:"Don't Forget Our Hashtag #shakyapp".localized, preferredStyle: .Alert)
        let SocialNetworks = UIAlertAction(title: "Social Networks".localized, style: .Default) { (action) in
            self.shareToInstagram()
        }
        let SaveToGallery = UIAlertAction(title: "Save LivePhoto to Camera Roll".localized, style: .Default) { (action) in
            self.exportLivePhoto()
        }
        let SaveSimpleToGallery = UIAlertAction(title: "Save Simple Photo to Camera Roll".localized, style: .Default) { (action) in
            UIImageWriteToSavedPhotosAlbum(UIImage(data: NSData(contentsOfFile: FilePaths.VidToLive.livePath.stringByAppendingString("/IMG.JPG"))!)!, self, "image:didFinishSavingWithError:contextInfo:", nil)
            
        }
        let cncl = UIAlertAction(title: "Cancel".localized, style: .Cancel) { (action) in
            
        }
        
        alertController.addAction(SocialNetworks)
        alertController.addAction(SaveToGallery)
        alertController.addAction(cncl)
        alertController.addAction(SaveSimpleToGallery)
        self.presentViewController(alertController, animated: true) {
            // ...
        }

        
    }
    
    
    
    func showPageView(){
        self.scrollView = nil
        //LastImg = images[Int(0)]
        self.showLivePhoto()
        if false{
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
    
    
    
    
    
    //new method special for live photos!!
    func loadVideoWithVideoURL(videoURL: NSURL) {
        livePhotoView?.livePhoto = nil
        let asset = AVURLAsset(URL: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = NSValue(CMTime: CMTimeMakeWithSeconds(CMTimeGetSeconds(asset.duration)/2, asset.duration.timescale))
        generator.generateCGImagesAsynchronouslyForTimes([time]) { [weak self] _, image, _, _, _ in
            if let image = image,data = UIImagePNGRepresentation(self!.ModernizeImage(UIImage(CGImage: image))) {
                let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
                let imageURL = urls[0].URLByAppendingPathComponent("image.jpg")
                data.writeToURL(imageURL, atomically: true)
                let image = imageURL.path
                let mov = videoURL.path
                let output = FilePaths.VidToLive.livePath
                let assetIdentifier = NSUUID().UUIDString
                let _ = try? NSFileManager.defaultManager().createDirectoryAtPath(output, withIntermediateDirectories: true, attributes: nil)
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(output.stringByAppendingString("/IMG.JPG"))
                    try NSFileManager.defaultManager().removeItemAtPath(output.stringByAppendingString("/IMG.MOV"))
                    
                } catch {
                    
                }
                JPEG(path: image!).write(output.stringByAppendingString("/IMG.JPG"),
                                         assetIdentifier: assetIdentifier)
                QuickTimeMov(path: mov!).write(output.stringByAppendingString("/IMG.MOV"),
                                               assetIdentifier: assetIdentifier)
                
                //self?.livePhotoView.livePhoto = LPDLivePhoto.livePhotoWithImageURL(NSURL(fileURLWithPath: FilePaths.VidToLive.livePath.stringByAppendingString("/IMG.JPG")), videoURL: NSURL(fileURLWithPath: FilePaths.VidToLive.livePath.stringByAppendingString("/IMG.MOV")))
                //self?.exportLivePhoto()
                PHLivePhoto.requestLivePhotoWithResourceFileURLs([ NSURL(fileURLWithPath: FilePaths.VidToLive.livePath.stringByAppendingString("/IMG.MOV")), NSURL(fileURLWithPath: FilePaths.VidToLive.livePath.stringByAppendingString("/IMG.JPG"))],
                                                                 placeholderImage: nil,
                                                                 targetSize: CGSizeMake(2000, 2000),
                                                                 contentMode: PHImageContentMode.AspectFill,
                                                                 resultHandler: { (livePhoto, info) -> Void in
                                                                    self?.livePhotoView?.livePhoto = livePhoto
                                                                    AudioServicesPlaySystemSound(1108)
                                                                    self?.recording = false
                                                                    //self?.exportLivePhoto()
                })
            }
        }
    }

    
    
    
    func exportLivePhoto () {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            let creationRequest = PHAssetCreationRequest.creationRequestForAsset()
            let options = PHAssetResourceCreationOptions()
            
            
            creationRequest.addResourceWithType(PHAssetResourceType.PairedVideo, fileURL: NSURL(fileURLWithPath: FilePaths.VidToLive.livePath.stringByAppendingString("/IMG.MOV")), options: options)
            creationRequest.addResourceWithType(PHAssetResourceType.Photo, fileURL: NSURL(fileURLWithPath: FilePaths.VidToLive.livePath.stringByAppendingString("/IMG.JPG")), options: options)
            
            }, completionHandler: { (success, error) -> Void in
                if error == nil {
                    let ac = UIAlertController(title: "Saved".localized, message: "Your Awesome Photo was Successfully Saved".localized, preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                } else {
                    let ac = UIAlertController(title: "Error!".localized, message: error?.localizedDescription, preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                }
                
        })
        
    }
    
    
    
    
}

