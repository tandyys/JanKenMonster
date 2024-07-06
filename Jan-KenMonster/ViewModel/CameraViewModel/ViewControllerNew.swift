//
//  ViewControllerNew.swift
//  Jan-KenMonster
//
//  Created by tandyys on 24/05/24.
//

import Cocoa
import AppKit
import Foundation
import AVFoundation
import Vision

class ViewControllerNew: NSViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate, ObservableObject {
    
    var permissionGranted = false
    var captureSession = AVCaptureSession()
    var sessionQueue = DispatchQueue(label: "sessionQueue")
    var previewLayer = AVCaptureVideoPreviewLayer()
    var screenRect: CGRect = NSScreen.main?.frame ?? .zero
    //    var videoOutput:AVCaptureVideoDataOutput
    var coordinator: VideoDetectorCoordinator?
    
    private var outputVideo = AVCaptureVideoDataOutput()
    var requests = [VNRequest]()
    var detectionLayer: CALayer! = nil
    var classes:[String] = []
    
    
    //    var previewView = NSImageView()
    //    var frameCounter = 0
    //    var frameInterval = 1
    //    var videoSize = CGSize.zero
    //    let colors:[NSColor] = {
    //        var colorSet:[NSColor] = []
    //        for _ in 0...80 {
    //            let color = NSColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
    //            colorSet.append(color)
    //        }
    //        return colorSet
    //    }()
    //    let ciContext = CIContext()
    //    var classes:[Int:String] = [:]
    
    //    lazy var yoloRequest:VNCoreMLRequest! = {
    //        do {
    //            let model = try best().model
    //            let classes = model.modelDescription.classLabels
    //            self.classes = classes
    //            let vnModel = try VNCoreMLModel(for: model)
    //            let request = VNCoreMLRequest(model: vnModel)
    //            return request
    //        } catch let error {
    //            fatalError("mlmodel error.")
    //        }
    //    }()
    
    override func viewDidLoad() {
        checkPermission()
        
        sessionQueue.async { [unowned self] in
            guard permissionGranted else { return }
            self.setupCaptureSession()
            
            self.setupLayers()
            self.setupDetector()
            
            self.captureSession.startRunning()
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }
    
    // MARK: ini kalo ga dipake dihapus aja ga si biar bersih?
    
    //    func setupVideo(){
    //        previewView.frame = view.bounds
    //        view.addSubview(previewView)
    //
    //        captureSession.beginConfiguration()
    //
    //        let device = AVCaptureDevice.default(for: AVMediaType.video)
    //        let deviceInput = try! AVCaptureDeviceInput(device: device!)
    //
    //        captureSession.addInput(deviceInput)
    //        videoOutput = AVCaptureVideoDataOutput()
    //
    //        let queue = DispatchQueue(label: "VideoQueue")
    //        videoOutput.setSampleBufferDelegate(self, queue: queue)
    //        captureSession.addOutput(videoOutput)
    //        if let videoConnection = videoOutput.connection(with: .video) {
    //            if videoConnection.isVideoOrientationSupported {
    //                videoConnection.videoOrientation = .portrait
    //            }
    //        }
    
    //        DispatchQueue.global(qos: .userInitiated).async {
    //            self.captureSession.startRunning()
    //        }
    //
    //        captureSession.commitConfiguration()
    
    //        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    //        previewLayer?.frame = previewView.bounds
    //        previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
    //        previewView.layer.addSublayer(previewLayer!)
    //
    //    }
    
    //    func detection(pixelBuffer: CVPixelBuffer) -> NSImage? {
    //        do {
    //            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
    //            try handler.perform([yoloRequest])
    //            guard let results = yoloRequest.results as? [VNRecognizedObjectObservation] else {
    //                return nil
    //            }
    //            var detections:[Detection] = []
    //            for result in results {
    //                let flippedBox = CGRect(x: result.boundingBox.minX, y: 1 - result.boundingBox.maxY, width: result.boundingBox.width, height: result.boundingBox.height)
    //                let box = VNImageRectForNormalizedRect(flippedBox, Int(videoSize.width), Int(videoSize.height))
    //
    //                guard let label = result.labels.first?.identifier as? String,
    //                        let colorIndex = classes.firstIndex(of: label) else {
    //                        return nil
    //                }
    //                let detection = Detection(box: box, confidence: result.confidence, label: label, color: colors[colorIndex])
    //                detections.append(detection)
    //            }
    //            let drawImage = drawRectsOnImage(detections, pixelBuffer)
    //            return drawImage
    //        } catch let error {
    //            print(error)
    //            return nil
    //        }
    //    }
    
    //    func drawRectsOnImage(_ detections: [Detection], _ pixelBuffer: CVPixelBuffer) -> NSImage? {
    //        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    //        let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)!
    //        let size = ciImage.extent.size
    //        guard let cgContext = CGContext(data: nil,
    //                                        width: Int(size.width),
    //                                        height: Int(size.height),
    //                                        bitsPerComponent: 8,
    //                                        bytesPerRow: 4 * Int(size.width),
    //                                        space: CGColorSpaceCreateDeviceRGB(),
    //                                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    //        cgContext.draw(cgImage, in: CGRect(origin: .zero, size: size))
    //        for detection in detections {
    //            let invertedBox = CGRect(x: detection.box.minX, y: size.height - detection.box.maxY, width: detection.box.width, height: detection.box.height)
    //            if let labelText = detection.label {
    //                cgContext.textMatrix = .identity
    //
    //                let text = "\(labelText) : \(round(detection.confidence*100))"
    //
    //                let textRect  = CGRect(x: invertedBox.minX + size.width * 0.01, y: invertedBox.minY - size.width * 0.01, width: invertedBox.width, height: invertedBox.height)
    //                let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    //
    //                let textFontAttributes = [
    //                    NSAttributedString.Key.font: NSFont.systemFont(ofSize: textRect.width * 0.1, weight: .bold),
    //                    NSAttributedString.Key.foregroundColor: detection.color,
    //                    NSAttributedString.Key.paragraphStyle: textStyle
    //                ]
    //
    //                cgContext.saveGState()
    //                defer { cgContext.restoreGState() }
    //                let astr = NSAttributedString(string: text, attributes: textFontAttributes)
    //                let setter = CTFramesetterCreateWithAttributedString(astr)
    //                let path = CGPath(rect: textRect, transform: nil)
    //
    //                let frame = CTFramesetterCreateFrame(setter, CFRange(), path, nil)
    //                cgContext.textMatrix = CGAffineTransform.identity
    //                CTFrameDraw(frame, cgContext)
    //
    //                cgContext.setStrokeColor(detection.color.cgColor)
    //                cgContext.setLineWidth(9)
    //                cgContext.stroke(invertedBox)
    //            }
    //        }
    //
    //        guard let newImage = cgContext.makeImage() else { return nil }
    //        let ciImages = CIImage(cgImage: newImage)
    //        let nsImage = NSImage(size: NSSize(width: ciImage.extent.width, height: ciImage.extent.height))
    //        nsImage.lockFocus()
    //        ciImage.draw(in: CGRect(origin: .zero, size: nsImage.size), from: CGRect(origin: .zero, size: ciImage.extent.size), operation: .copy, fraction: 1.0)
    //        nsImage.unlockFocus()
    //        return nsImage
    //
    //    }
    
    //    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    //        frameCounter += 1
    //        if videoSize == CGSize.zero {
    //            guard let width = sampleBuffer.formatDescription?.dimensions.width,
    //                  let height = sampleBuffer.formatDescription?.dimensions.height else {
    //                fatalError()
    //            }
    //            videoSize = CGSize(width: CGFloat(width), height: CGFloat(height))
    //        }
    //        if frameCounter == frameInterval {
    //            frameCounter = 0
    //            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    //            guard let drawImage = detection(pixelBuffer: pixelBuffer) else {
    //                return
    //            }
    //            DispatchQueue.main.async {
    //                self.previewView.image = drawImage
    //            }
    //        }
    //    }
    
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            // Permission has been granted before
        case .authorized:
            permissionGranted = true
            
            // Permission has not been requested yet
        case .notDetermined:
            requestPermission()
            
        default:
            permissionGranted = false
        }
    }
    
    func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    func setupCaptureSession() {
        // Camera input
        guard let videoDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        // Preview layer
        let screenRect: CGRect = NSScreen.main?.frame ?? .zero
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill // Fill screen
        //        previewLayer.connection?.videoOrientation = .landscapeRight
        
        // Detector
        outputVideo.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(outputVideo)
        
        //        videoOutput.connection(with: .video)?.videoOrientation = .landscapeRight
        
        // Updates to UI must be on main queue
        DispatchQueue.main.async { [weak self] in
            if let previewLayer = self?.previewLayer {
                self?.view.layer?.addSublayer(previewLayer)
            }
        }
        
    }
    
    //struct Detection {
    //    let box:CGRect
    //    let confidence:Float
    //    let label:String?
    //    let color:NSColor
    //}
}
