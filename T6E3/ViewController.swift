//
//  ViewController.swift
//  T6E3
//
//  Created by Jorge Marquez Torres on 2/2/16.
//  Copyright © 2016 jmarquez. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet var previewView: UIView!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureSession : AVCaptureSession!
    var metadataOutput: AVCaptureMetadataOutput!
    var videoDevice:AVCaptureDevice!
    var videoInput: AVCaptureDeviceInput!
    var running = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCaptureSession() //Implementado posteriormente
        previewLayer.frame = previewView.bounds
        previewView.layer.addSublayer(previewLayer)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "startRunning:", name:
            UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "stopRunning:", name:
            UIApplicationDidEnterBackgroundNotification, object: nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.startRunning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopRunning()
    }
    
    func startRunning(){
        captureSession.startRunning()
        metadataOutput.metadataObjectTypes =
            metadataOutput.availableMetadataObjectTypes
        running = true
    }
    
    func stopRunning(){
        captureSession.stopRunning()
        running = false
    }
    
    func setupCaptureSession() {
        if(captureSession != nil){
            return
        }
        videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if(videoDevice == nil){
            print("No camera on this device")
        }
        captureSession = AVCaptureSession()
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoDevice) as AVCaptureDeviceInput
        } catch let error as NSError {
            print(error)
        }
        if(captureSession.canAddInput(videoInput)){
            captureSession.addInput(videoInput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        metadataOutput = AVCaptureMetadataOutput()
        let metadataQueue = dispatch_queue_create("com.jmarquez.T6E3.metadata", nil)
        metadataOutput.setMetadataObjectsDelegate(self, queue: metadataQueue)
        if(captureSession.canAddOutput(metadataOutput)){
            captureSession.addOutput(metadataOutput)
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!,
        didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection
        connection: AVCaptureConnection!) {
            let elemento = metadataObjects.first as? AVMetadataMachineReadableCodeObject
            if(elemento != nil){
                print(elemento!.stringValue)
                let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let viewController:UIViewController = storyboard.instantiateViewControllerWithIdentifier("webViewController") as UIViewController
                self.presentViewController(viewController, animated: true, completion: nil)
            }
    }


}

