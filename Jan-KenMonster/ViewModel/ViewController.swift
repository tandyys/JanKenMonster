//
//  ViewController.swift
//  Jan-KenMonster
//
//  Created by tandyys on 24/05/24.
//

import Foundation
import AVFoundation
import AppKit
import Vision

class ViewController: NSViewController, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var bufferSize: CGSize = .zero
    private let session = AVCaptureSession()
    
//    @IBOutlet weak var previewView: NSView!
    
    var rootLayer: CALayer!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var detectionLayer: CALayer!
    
    private var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCapture()
        setupOutput()
        setupLayers()
        try? setupVision()
        session.startRunning()
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
            // Clean up the capture session
            for input in session.inputs {
                session.removeInput(input)
            }
            for output in session.outputs {
                session.removeOutput(output)
            }
        }
    }
    
    func setupCapture() {
        var deviceInput: AVCaptureDeviceInput!
        let videoDevice = AVCaptureDevice.default(for: .video)
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Can't find camera device")
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .vga640x480
        
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        
        session.addInput(deviceInput)
        
        do {
            try  videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        
        session.commitConfiguration()
        
        
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }
    
    func setupOutput() {
        let videoDataOutput = AVCaptureVideoDataOutput()
        let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
                
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
    }
    
    func setupLayers() {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        rootLayer = previewView?.layer
//        if let rootLayer = previewView?.layer {
//            previewLayer.frame = rootLayer.bounds
//            rootLayer.addSublayer(previewLayer)
//        } else {
//            print("Error: previewView is nil")
//        }
//        previewLayer.frame = rootLayer!.bounds
//        rootLayer.addSublayer(previewLayer)
        
        detectionLayer = CALayer()
        detectionLayer.bounds = CGRect(
            x: 0.0,
            y: 0.0,
            width: bufferSize.width,
            height: bufferSize.height
        )
        detectionLayer.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionLayer)
        
        let xScale: CGFloat = rootLayer.bounds.size.width / bufferSize.height
        let yScale: CGFloat = rootLayer.bounds.size.height / bufferSize.width
            
        let scale = fmax(xScale, yScale)
            
        detectionLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        detectionLayer.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
    }
    
    func setupVision() throws {
        let model = try best().model
            
        do {
            let visionModel = try VNCoreMLModel(for: model)
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    if let results = request.results {
                        self.drawResults(results)
                    }
                })
            })
            self.requests = [objectRecognition]
            } catch let error as NSError {
                print("Model loading went wrong: \(error)")
            }
        }
    
    func drawResults(_ results: [Any]) {
        
        func createRoundedRectLayerWithBounds(bounds: CGRect) -> CALayer {
            let layer = CALayer()
            layer.bounds = bounds
            layer.cornerRadius = 10 // Example value for corner radius
            layer.borderWidth = 2 // Example value for border width
            layer.borderColor = NSColor.blue.cgColor // Example color for border
            layer.masksToBounds = true // Ensure that content within the layer is clipped to its bounds
            return layer
        }
        
        func createDetectionTextLayer(objectBounds: CGRect, formattedString: NSMutableAttributedString) -> CATextLayer {
            let textLayer = CATextLayer()
            textLayer.string = formattedString
            textLayer.frame = CGRect(x: objectBounds.origin.x, y: objectBounds.origin.y - 20, width: objectBounds.width, height: 20) // Adjust the position as needed
            // Additional text layer customization...
            return textLayer
        }
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        detectionLayer.sublayers = nil // Clear previous detections from detectionLayer
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
                
            let topLabelObservation = objectObservation.labels[0]
                
            let boundingBox = CGRect(origin: CGPoint(
                x:1.0-objectObservation.boundingBox.origin.y-objectObservation.boundingBox.size.height,
                y:objectObservation.boundingBox.origin.x
            ), size: CGSize(
                width:objectObservation.boundingBox.size.height,
                height:objectObservation.boundingBox.size.width
            ))
                    
            let objectBounds = VNImageRectForNormalizedRect(boundingBox, Int(bufferSize.width), Int(bufferSize.height))
                    
            let shapeLayer = createRoundedRectLayerWithBounds(bounds: objectBounds)
                    
            let formattedString = NSMutableAttributedString(string: String(
                format: "\(topLabelObservation.identifier)\n %.1f%% ",
                topLabelObservation.confidence*100).capitalized)
                    
            let textLayer = createDetectionTextLayer(objectBounds: objectBounds, formattedString: formattedString)
            shapeLayer.addSublayer(textLayer)
            detectionLayer.addSublayer(shapeLayer)
        }
        
        CATransaction.commit()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
           
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        do {
            let start = CACurrentMediaTime()
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    

}

