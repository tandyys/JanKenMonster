//
//  AccessCameraVM.swift
//  Jan-KenMonster
//
//  Created by tandyys on 22/05/24.
//

import Foundation
import AVFoundation
import SwiftUI

class CameraCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?

    override init() {
        super.init()
        
        guard let camera = AVCaptureDevice.default(for: .video) else {
            fatalError("No camera available")
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            captureSession.addInput(input)
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(output)
        } catch {
            fatalError("Failed to setup camera capture: \(error.localizedDescription)")
        }
    }
    
    func startCapture() {
        captureSession.startRunning()
    }
    
    func stopCapture() {
        captureSession.stopRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Perform your computer vision processing on the captured frames here
        // Use Core ML and Vision frameworks to apply your machine learning model
    }
}

struct CameraView: NSViewRepresentable {
    let cameraCapture = CameraCapture()
    
    func makeNSView(context: Context) -> NSView {
        let cameraView = NSView()
        
        // Add camera preview layer to the view
        if let previewLayer = cameraCapture.previewLayer {
            cameraView.layer?.addSublayer(previewLayer)
        }
        
        return cameraView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // Start or stop capturing frames based on the view's lifecycle
        if context.coordinator == nil {
            cameraCapture.startCapture()
        } else {
            cameraCapture.stopCapture()
        }
    }
    
    typealias NSViewType = NSView
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
//    class Coordinator: NSObject {
//        // Implement any additional coordination logic here
//    }
}
