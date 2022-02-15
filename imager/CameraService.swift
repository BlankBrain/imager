//
//  CameraService.swift
//  imager
//
//  Created by Md. Mehedi Hasan on 15/2/22.
//

import Foundation
import AVFoundation


class CameraService{
    var session: AVCaptureSession?
    var delegate: AVCapturePhotoCaptureDelegate?
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    
    func Start(delegate: AVCapturePhotoCaptureDelegate  , completion: @escaping () -> (Error?)){
        
        self.delegate = delegate
        
    }
    private func checkPermissions(completion: @escaping () -> (Error?)){
        
        switch AVCaptureDevice.authorizationStatus(for: .video){
            
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in guard granted else { return }
            })
            
            DispatchQueue.main.async {
                self.setupCamera(completion: completion)
            }
            
            
        case .restricted:
            break
        case .denied:
            break
            
            
        case .authorized:
            setupCamera(completion: completion)
            
            
        @unknown default:
            break
        }
        
        
    }
    
    private func setupCamera(completion: @escaping () -> (Error?)){
        let session = AVCaptureSession()
        if let Device = AVCaptureDevice.default(for: .video){
            
            do{
                let input = try AVCaptureDeviceInput(device: Device)
                if session.canAddInput(input){
                    session.addInput(input)
                }
                if session.canAddOutput(output){
                    session.addOutput(output)
                }
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                session.startRunning()
                self.session = session
                
            }catch{
                print(error)
            }
        }
    }
    
    func capturePhoto( with  settings: AVCapturePhotoSettings = AVCapturePhotoSettings())
    {
        output.capturePhoto(with: settings, delegate: delegate!)
    }
}
