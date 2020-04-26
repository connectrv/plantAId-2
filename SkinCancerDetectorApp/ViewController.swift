//
//  AppDelegate.swift
//  Dermaogix
//
//  Created by Krish Malik on 4/24/2020.
//  Copyright © 2018 Krish Malik. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    

    @IBOutlet var cameraView: UIView!
    
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var textLabel2: UILabel!
    
    let blightText = "Tomato___Early_blight"
    let septoriaText = "Tomato___Septoria_leaf_spot"
    let measlesText = "Measles"
    let malignantText = "Malignant Melanoma"
    let targetSpotText = "Tomato___Target_Spot"
    let peachHealthy = "Peach___healthy"
    let blueberryHealthy = "Blueberry___healthy"
    let cornText = "Corn_(maize)___Northern_Leaf_Blight"
    let grapeBlackMeasles = "Grape___Esca_(Black_Measles)"
    let tomatoHealthy = "Tomato___healthy"
    
    

    
    @IBAction func photoButton(_ sender: Any) {
        if self.textLabel.text == self.blightText {
            self.performSegue(withIdentifier: "photoToBlight", sender: nil)
            }
        else if self.textLabel.text == self.measlesText {
            self.performSegue(withIdentifier: "ScanToMeasles", sender: nil)
            }
        else if self.textLabel.text == self.septoriaText {
            self.performSegue(withIdentifier: "photoToSeptoria", sender: nil)
            }
        else if self.textLabel.text == self.malignantText {
            self.performSegue(withIdentifier: "ScanToMalignant", sender: nil)
        }
        else if self.textLabel.text == self.targetSpotText {
            self.performSegue(withIdentifier: "photoToTargetSpot", sender: nil)
        }
        else if self.textLabel.text == self.peachHealthy {
            self.performSegue(withIdentifier: "photoToPeach", sender: nil)
        }
        else if self.textLabel.text == self.blueberryHealthy {
            self.performSegue(withIdentifier: "photoToBlueberry", sender: nil)
        }
        else if self.textLabel.text == self.cornText {
            self.performSegue(withIdentifier: "photoToCorn", sender: nil)
        }
        else if self.textLabel.text == self.grapeBlackMeasles {
            performSegue(withIdentifier: "photoToGrapeBlackMeasles", sender: nil)
        }
        else if self.textLabel.text == self.tomatoHealthy {
            performSegue(withIdentifier: "photoToTomato", sender: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        
        
        previewLayer.frame = self.cameraView.layer.bounds
        previewLayer.contentsGravity = CALayerContentsGravity.center
        
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        
        self.cameraView.layer.addSublayer(previewLayer)
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        captureSession.addOutput(dataOutput)
        
        
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //print(Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: coreml_model().model) else { return }
        
        let request = VNCoreMLRequest(model: model) {
            (finishedReq, err) in
            
            //print(finishedReq.results)
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            
            
            guard let firstObservation = results.first else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            
            DispatchQueue.main.async {
                let snippet = firstObservation.identifier
                
                /*
                if let range = snippet.range(of: " ") {
                    let trimmedText = snippet[range.upperBound...]
                    
                    self.textLabel.text = "\(trimmedText)"
                    
                }
 
 */
                
                self.textLabel.text = "\(snippet)"
                
                
                self.textLabel2.text = "\(Double(firstObservation.confidence * 100).roundTo2f())%"
                
                
                
            }
        }
        
        
        
        
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    

    


}

extension Double {
    func roundTo2f() -> NSString
    {
        return NSString(format: "%.2f", self)
    }
}

