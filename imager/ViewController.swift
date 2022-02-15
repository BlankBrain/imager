//
//  ViewController.swift
//  imager
//
//  Created by Md. Mehedi Hasan on 15/2/22.
//

import UIKit
import Vision
import AVFoundation

class ViewController: UIViewController  , AVCapturePhotoCaptureDelegate{
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        checkPermissions()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        PreviewLayer.frame = imageview.frame
    }
    @IBAction func CapturePhoto(_ sender: Any) {
        
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    //MARK: ================  Camera ================
    
    //MARK: 1. Capture session
    var session: AVCaptureSession?
    
    //MARK: 2. Photo Output
    var output = AVCapturePhotoOutput()
    //MARK: 3. Video Preview
    var PreviewLayer = AVCaptureVideoPreviewLayer()
    // MARK: UI
    
    
    
    
    
    //MARK: Text recognition
    func recogniseText(image: UIImage?)  {
        guard let cgImage = image?.cgImage else{
            return
        }
        
        //MARK: Handeler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        //MARK: Process
        let request = VNRecognizeTextRequest{ [weak self]
            request, error in
            guard let observations = request.results as?[ VNRecognizedTextObservation],
                  error == nil else{
                      return
                  }
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: " ")
            DispatchQueue.main.async {
                self?.textLabel.text = text
            }
        }
        
        //MARK: process request
        do{
            try handler.perform([request])
        }catch{
            print(error)
        }
    }
    
     func checkPermissions(){
        
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: {[weak self] granted in guard granted else { return }
            })
            DispatchQueue.main.async {
            self.setupCamera() }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupCamera()
        @unknown default:
            break
        }
        
        
    }
     func setupCamera(){
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
                PreviewLayer.videoGravity = .resizeAspectFill
                PreviewLayer.session = session
                session.startRunning()
                self.session = session
                
            }catch{
                print(error)
            }
        }
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else{
            return
        }
        session?.stopRunning()
        let image = UIImage(data: data)
        self.imageview.image = image
        PreviewLayer.frame = imageview.frame
        view.layer.addSublayer(PreviewLayer)
        imageview.contentMode = .scaleAspectFill
        recogniseText(image: self.imageview.image)
        session?.startRunning()

    }
}


