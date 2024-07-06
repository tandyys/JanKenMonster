//
//  CameraDetectionCoordinator.swift
//  Jan-KenMonster
//
//  Created by tandyys on 24/05/24.
//

import Foundation
import AVFoundation

class VideoDetectorCoordinator {
    var handPoseOb: HandPoseObservable?

    init(handPoseOb: HandPoseObservable) {
        self.handPoseOb = handPoseOb
    }
}

class HandPoseObservable: AVCaptureVideoPreviewLayer, ObservableObject {
    @Published var detectedHandPose: [String: Bool] = [:]

    func resetDetectedItems() {
        detectedHandPose = [:]
    }

}
