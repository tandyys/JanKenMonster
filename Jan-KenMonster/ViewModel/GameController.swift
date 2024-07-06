//
//  GameController.swift
//  Jan-KenMonster
//
//  Created by tandyys on 26/05/24.
//

import Foundation
import Combine
import SDWebImage
import SDWebImageSwiftUI

class GameViewModel: ObservableObject {
    
    let handposeResult = HandPoseClassifier().predictionResult
    
    @Published var showRedGif: Bool = false
    @Published var showBlueGif: Bool = false
    @Published var playerMove: Move?
    @Published var computerMove: Move?
    @Published var gameResult: GameResult?
    
    func play(move: Move) {
        if handposeResult == "rock" {
            playerMove = Move.rock
        } else if handposeResult == "scissors"{
            playerMove = Move.scissors
        }
        computerMove = Move.paper
        if let playerMove = playerMove, let computerMove = computerMove {
            let game = Game(playerMove: playerMove, computerMove: computerMove)
            gameResult = game.getResult()
            
            if gameResult == .redWin {
                showRedGif = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.showRedGif = false
                }
            } else if gameResult == .blueWin {
                showBlueGif = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.showBlueGif = false
                }
            }
            
        }
    }
}
