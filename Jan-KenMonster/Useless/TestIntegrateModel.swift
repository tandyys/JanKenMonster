//
//  TestIntegrateModel.swift
//  Jan-KenMonster
//
//  Created by tandyys on 24/05/24.
//

//import SwiftUI
//import AVFoundation
//
//struct TestIntegrateModel: View {
//    @StateObject private var cameraController = CameraController()
//    @StateObject private var handDetection = ViewController()
//    @StateObject private var handDetect = ViewControllerNew()
//
//    var body: some View {
//        VStack {
//            VideoDetectorView(handposeOb: handDetect.getPreviewLayer())
//                .onAppear {
//                    handDetect.viewDidLoad()
//                }
//                .onDisappear {
//                    handDetect.stopSession()
//                }
//        }
        
//        VStack {
//            
//        }
//    }
//}

//struct NSViewControllerWrapper: NSViewControllerRepresentable {
//    func makeNSViewController(context: Context) -> ViewController {
//        let viewController = ViewController()
//        return viewController
//    }
//    
//    func updateNSViewController(_ nsViewController: ViewController, context: Context) {
//            // Update the view controller if needed
//    }
//}

//struct CameraPreviewView: NSViewRepresentable {
//    
//    var previewLayer: AVCaptureVideoPreviewLayer
//
//    func makeNSView(context: Context) -> NSView {
//        let view = NSView()
//        view.layer = previewLayer
//        previewLayer.frame = view.bounds
//        previewLayer.videoGravity = .resizeAspectFill
//        return view
//    }
//
//    func updateNSView(_ nsView: NSView, context: Context) {
//        previewLayer.frame = nsView.bounds
//    }
//    
//}

//struct VideoDetectorView: NSViewControllerRepresentable {
//    
//    var handposeOb: HandPoseObservable
//    
//    func makeNSViewController(context: Context) -> NSViewController {
//        let controller = ViewControllerNew()
//        controller.coordinator = VideoDetectorCoordinator(handPoseOb: handposeOb)
//        return controller
//    }
//    
//    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
//        
//    }
//}
//
//#Preview {
//    TestIntegrateModel()
//}
