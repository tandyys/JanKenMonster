//
//  HomeView.swift
//  Jan-KenMonster
//
//  Created by tandyys on 22/05/24.
//

import SwiftUI

struct HomeView: View {
    
    @State private var isSecondViewActive:Bool = false
    @StateObject var audioPlayer = AudioController()
    
    var body: some View {
//        NavigationView {
            VStack {
                
                Image("Title Game")
                
                Button(action: {
                    print("Button tapped")
                    self.isSecondViewActive = true
                }) {
                    Image("Play Button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 285, height: 77)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 100)
            }
            .homeBackground()
//            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $isSecondViewActive){
                GameplayView()
//                .onAppear {
//                    audioPlayer.stopMusic()
//                }
            }
            .onAppear {
                audioPlayer.playMusic()
            }
//        }
    }
}

extension View {
    func homeBackground()-> some View {
        self.background(
            Image("HomeEnv")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
                .frame(width: NSScreen.main?.frame.width, height: NSScreen.main?.frame.height)
                .clipped()
                .edgesIgnoringSafeArea(.all)
        )
    }
}

#Preview {
    HomeView()
}
