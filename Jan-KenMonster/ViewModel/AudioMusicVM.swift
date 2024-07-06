//
//  AudioMusicVM.swift
//  Jan-KenMonster
//
//  Created by tandyys on 23/05/24.
//

import Foundation
import AVFoundation

class AudioController: NSObject, ObservableObject {
    
    var audioPlayer = AVAudioPlayer()
    
    func playMusic() {
        guard let musicPath = Bundle.main.path(forResource: "RPG Music Adventure", ofType: "wav") else {
                    print("Music file not found")
                    return
                }

                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: musicPath))
                    audioPlayer.numberOfLoops = -1
                    audioPlayer.play()
                } catch {
                    print("Failed to initialize audio player: \(error.localizedDescription)")
                }
    }
    
    func stopMusic() {
        audioPlayer.stop()
    }
    
}
