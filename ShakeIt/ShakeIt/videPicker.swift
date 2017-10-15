//
//  videPicker.swift
//  ShakeIt
//
//  Created by Denis Karpenko on 27.04.16.
//  Copyright © 2016 Denis Karpenko. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoPickerDelegate: NSObjectProtocol {
    func updateVideo()
    func showAlert(message:String)
    
}

class videPicker: NSObject,AVCaptureFileOutputRecordingDelegate {
    var link:NSURL?
    weak var delegate:VideoPickerDelegate?
    var cameraSession: AVCaptureSession?
    
    func setupCameraSession() {
        cameraSession = AVCaptureSession()
        cameraSession!.sessionPreset = AVCaptureSessionPresetHigh
        //cameraSession!.sessionPreset = AVCaptureSessionPresetInputPriority
        let availableCameraDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        var frontCameraDevice:AVCaptureDevice?
        for device in availableCameraDevices as! [AVCaptureDevice] {
            if device.position == .Back {
            }
            else if device.position == .Front {
                frontCameraDevice = device
            }
        }
        
        let captureDevice = frontCameraDevice

        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            cameraSession!.beginConfiguration()
            
            if (cameraSession!.canAddInput(deviceInput) == true) {
                cameraSession!.addInput(deviceInput)
            }
//            do {
//                try captureDevice!.lockForConfiguration()
//                captureDevice?.activeFormat = captureDevice?.formats.last as! AVCaptureDeviceFormat
//                
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
            //captureDevice?.unlockForConfiguration()
//            let audio = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
//            do{
//            let inp = try  AVCaptureDeviceInput(device: audio)
//            if (cameraSession!.canAddInput(inp) == true) {
//                cameraSession!.addInput(inp)
//            }
//            }catch {
//                print("error!")
//            }
            
            
            cameraSession!.commitConfiguration()
            
            
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
    }
    
    func config(){
        let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch authorizationStatus {
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo,
                                                      completionHandler: { (granted:Bool) -> Void in
                                                        if granted {
                                                            self.setupCameraSession()
                                                        }
                                                        else {
                                                            self.delegate?.showAlert("Application can't Work without Permission to use the Camera".localized)
                                                            //self.showAccessDeniedMessage()
                                                        }
            })
        case .Authorized:
            setupCameraSession()
        case .Denied, .Restricted:
            self.delegate?.showAlert("Allow Shaky to Access the Camera in the Phone Settings!".localized)
        }

    }
    func makeVideo() {
        //REMAKE THIS!!!!!! CAN BE ERROR
        self.setupCameraSession()
        cameraSession!.beginConfiguration()
        let movieFileOutput = AVCaptureMovieFileOutput()
        //movieFileOutput.maxRecordedDuration = CMTime(seconds: 4, preferredTimescale: 1)
        
        if (cameraSession!.canAddOutput(movieFileOutput) == true) {
            cameraSession!.addOutput(movieFileOutput)
        }
        // Start recordin
        let writePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("viduvuv.mov")
        let manager = NSFileManager.defaultManager()
        let outputURL = NSURL(fileURLWithPath: writePath)
        if(manager.fileExistsAtPath(writePath)){
        do{
        try manager.removeItemAtURL(outputURL)
        } catch let error as NSError {
            print ("Error: \(error.domain)")
        }
        }
        cameraSession!.commitConfiguration()
        cameraSession!.startRunning()
        movieFileOutput.startRecordingToOutputFileURL(outputURL, recordingDelegate: self)
        delay(1.5){
            movieFileOutput.stopRecording()
        }
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if (error==nil){
            print("succes!")
            link =  outputFileURL
            delegate?.updateVideo()
            cameraSession!.stopRunning()
        }
        else{
            print(error.code)//handle
        }
    }
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("Started!!")
    }
}
