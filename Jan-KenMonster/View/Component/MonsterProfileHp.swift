//
//  MonsterProfileHp.swift
//  Jan-KenMonster
//
//  Created by tandyys on 22/05/24.
//

import SwiftUI

struct MonsterProfileHp: View {
    var body: some View {
        HStack {
            Image("BlueMonster")
                .padding()
            Spacer()
            Image("RedMonster")
                .padding()
        }
    }
}

#Preview {
    MonsterProfileHp()
}
