//
//  AccessCameraVM3.swift
//  Jan-KenMonster
//
//  Created by tandyys on 24/05/24.
//

import Foundation
import AVFoundation
import Vision

class CameraController: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureVideoDataOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let maxQueueSize = 10
    private var sampleBufferQueue: DispatchQueue = DispatchQueue(label: "sampleBufferQueue")
    

    override init() {
        super.init()
        setupCamera()
    }

    func setupCamera() {
            captureSession = AVCaptureSession()
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let videoInput: AVCaptureDeviceInput
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                return
            }

            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                return
            }

            videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            } else {
                return
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill

            captureSession.startRunning()
        }
    
    func startSession() {
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
        }

        func stopSession() {
            if captureSession.isRunning {
                captureSession.stopRunning()
                // Clean up the capture session
                for input in captureSession.inputs {
                    captureSession.removeInput(input)
                }
                for output in captureSession.outputs {
                    captureSession.removeOutput(output)
                }
            }
        }
    
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        return previewLayer
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Process the sample buffer
        processFrame(sampleBuffer: sampleBuffer)
    }
    
//    private func enqueueSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
//            sampleBufferQueue.async { [weak self] in
//                // Check if the queue size exceeds the maximum limit
//                if self?.sampleBufferQueue.count ?? 0 >= self?.maxQueueSize ?? 0 {
//                    // Drop or discard the sample buffer
//                    return
//                }
//                
//                // Process the sample buffer
//                self?.processFrame(sampleBuffer: sampleBuffer)
//            }
//        }
    
    func processFrame(sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        // Pass the pixel buffer to the Vision framework
        performVisionRequest(pixelBuffer: pixelBuffer)
    }
    
    
    func performVisionRequest(pixelBuffer: CVPixelBuffer) {
            do {
                let visionModel = try VNCoreMLModel(for: model.model)
                let request = VNCoreMLRequest(model: visionModel) { request, error in
                    if let results = request.results as? [VNRecognizedObjectObservation] {
                        self.handleDetections(results: results)
                        print("Result: \(results)")
                    } else if let error = error {
                        print("Error during vision request: \(error)")
                    }
                }

                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
                try handler.perform([request])
            } catch {
                print("Failed to create VNCoreMLModel or perform request: \(error)")
            }
        }

    func handleDetections(results: [VNRecognizedObjectObservation]) {
        for detection in results {
            print("Detected object: \(detection.labels.first?.identifier ?? "unknown") with confidence: \(detection.confidence)")
                // Update your UI with the detection results
        }
    }

}
