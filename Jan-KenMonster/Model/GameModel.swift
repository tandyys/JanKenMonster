//
//  GameModel.swift
//  Jan-KenMonster
//
//  Created by tandyys on 26/05/24.
//

import Foundation

enum Move: String, CaseIterable {
    case rock = "rock"
    case paper = "paper"
    case scissors = "scissors"
}

enum GameResult: String {
    case blueWin = "BLUE MONSTER WIN"
    case redWin = "RED MONSTER WIN"
}

struct Game {
    let playerMove: Move
    let computerMove: Move
    
    func getResult() -> GameResult {
        switch (playerMove, computerMove) {
        case (.scissors, .paper):
            return .blueWin
        default:
            return .redWin
        }
    }
}
