//
//  FullHearts.swift
//  Jan-KenMonster
//
//  Created by tandyys on 26/05/24.
//

import SwiftUI

struct FullHearts: View {
    var body: some View {
        HStack {
            fullHeartsProfile()
                .padding(.leading,15)
            fullHeartsProfile()
                .padding(.leading, -5)
            fullHeartsProfile()
                .padding(.leading, -10)
        }
    }
}

extension FullHearts {
    func fullHeartsProfile() -> some View {
        Rectangle()
        .foregroundColor(.clear)
        .frame(width: 84, height: 83)
        .background(
        Image("Full Heart")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 84, height: 83)
        .clipped()
        )
    }
}

#Preview {
    FullHearts()
}
