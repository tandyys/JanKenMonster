//
//  gifTesting.swift
//  Jan-KenMonster
//
//  Created by tandyys on 26/05/24.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct gifTesting: View {
    var body: some View {
        AnimatedImage(name: "blueMonsterAttack")
            .resizable()
//            .frame(width: 500, height: 500)
    }
}

#Preview {
    gifTesting()
}
