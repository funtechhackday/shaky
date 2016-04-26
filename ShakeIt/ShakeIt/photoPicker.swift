//
//  photoPicker.swift
//  ShakeIt
//
//  Created by Denis Karpenko on 17.02.16.
//  Copyright © 2016 Denis Karpenko. All rights reserved.
//

import UIKit
import AVFoundation

protocol PhotoPickerDelegate: NSObjectProtocol {
    func updatePhoto()
    func showAlert(message:String)

}


class photoPicker: NSObject {
    
    //AV Foundation variables
    var lastPick: UIImage?
    var captureSession: AVCaptureSession? = nil
    var stillImageOutput: AVCaptureStillImageOutput? = nil
    let previewLayer: AVCaptureVideoPreviewLayer? = nil
    weak var delegate:PhotoPickerDelegate?
    override init() {
        super.init()
    }
    
    func configureSession(){
        
        let availableCameraDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        var backCameraDevice:AVCaptureDevice?
        var frontCameraDevice:AVCaptureDevice?
        for device in availableCameraDevices as! [AVCaptureDevice] {
            if device.position == .Back {
                backCameraDevice = device
            }
            else if device.position == .Front {
                frontCameraDevice = device
            }
        }

        do {
            try frontCameraDevice!.lockForConfiguration()
            //adjust!
            let activeFormat = frontCameraDevice!.activeFormat
            //let duration = activeFormat.minExposureDuration
            //let iso = activeFormat.maxISO
            //frontCameraDevice?.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            print(AVCaptureExposureDurationCurrent)
            //frontCameraDevice?.setExposureModeCustomWithDuration(activeFormat.maxExposureDuration, ISO: activeFormat.maxISO, completionHandler: nil)
            frontCameraDevice?.setExposureTargetBias(1, completionHandler: nil)
            frontCameraDevice!.unlockForConfiguration()
            
        } catch let error as NSError {
            if error.code == 0 {
                print("Error code: 0")
            }
        }
        
        let input = try? AVCaptureDeviceInput(device: frontCameraDevice)
        if captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
        }
        else{
            print("error")// need to push nortification
        }
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        captureSession!.addOutput(stillImageOutput)
        
        print("ok")
        
    }
    
    
    func initializeSession() {
        
        self.captureSession = AVCaptureSession()
        captureSession!.startRunning()
        self.captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        switch authorizationStatus {
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo,
                completionHandler: { (granted:Bool) -> Void in
                    if granted {
                        self.configureSession()
                    }
                    else {
                        self.delegate?.showAlert("Application can't Work without Permission to use the Camera".localized)
                        //self.showAccessDeniedMessage()
                    }
            })
        case .Authorized:
            configureSession()
        case .Denied, .Restricted:
            self.delegate?.showAlert("Allow Shaky to Access the Camera in the Phone Settings!".localized)
        }
        
    }
    
    func CapturePhoto(){
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo) {
            NSLog("start photo")
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if error == nil {
                    // if the session preset .Photo is used, or if explicitly set in the device's outputSettings
                    // we get the data already compressed as JPEG
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    
                    if let image = UIImage(data: imageData) {
                        NSLog("end photo")
                        self.lastPick = image
                        self.delegate?.updatePhoto()
                        // save the image or do something interesting with it
                    }
                }
                else {
                    NSLog("error while capturing still image: \(error)")
                }
            })
        }
    }
}
