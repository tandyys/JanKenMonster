//
//  GameplayView.swift
//  Jan-KenMonster
//
//  Created by tandyys on 22/05/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct GameplayView: View {
    
    @StateObject var frameHandler = FrameHandler()
    @StateObject var cameraModel = HandPoseClassifier()
    
    @ObservedObject var gameVM = GameViewModel()
    
    var body: some View {
        ZStack {
            Color.clear
            
            cameraPreview()
                .onAppear {
                    frameHandler.startSession()
                }
                .onDisappear {
                    frameHandler.stopSession()
                }
            
            Text(cameraModel.predictionResult ?? "Unknown")
            if let errorMessage = cameraModel.errorMessage {
                Text(errorMessage)
                    .padding()
            }
            
            VStack {
                ZStack {
                    MonsterProfileHp()
                    HStack {
                        FullHearts()
                            .padding(.leading, 205)
                            .padding(.top, 15)
                        Spacer()
                        FullHearts()
                            .padding(.trailing, 225)
                            .padding(.top, 15)
                    }
                }
                Spacer()
                MonsterAndFloor()
            }
            
            if cameraModel.predictionResult == "scissors" {
                    Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                    AnimatedImage(name: "blueMonsterAttack")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
            } else if cameraModel.predictionResult == "rock" {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                AnimatedImage(name: "redMonsterAttack")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
//            if gameVM.showRedGif == true {
//                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
//                    AnimatedImage(name: "redMonsterAttack")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
////                        .frame(width: 300, height: 300)
//            } else if gameVM.showBlueGif == true{
//                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
//                    AnimatedImage(name: "blueMonsterAttack")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
////                        .frame(width: 300, height: 300)
//            }
            
        }
    }
}

extension GameplayView {
    
    func cameraPreview()-> some View {
        GeometryReader { geometry in
            if let frame = frameHandler.frame {
                Image(decorative: frame,
                      scale: 1.0,
                      orientation: .up)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width,
                       height: geometry.size.height)
                .clipped()
            } else {
                Text("Starting the game...")
                    .font(Font.custom("Press Start 2P", size: 38))
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height)
                    .background(Color.black)
                    .foregroundColor(.white)
            }
        }
    }

}

#Preview {
    GameplayView()
}
