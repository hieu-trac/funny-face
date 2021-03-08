//
//  PropChooser.swift
//  funnyface
//
//  Created by Hieu C Trac on 3/6/21.
//

import SwiftUI
import RealityKit

enum Prop: CaseIterable, Equatable {
    case fancyHat, speechBubble, eyeball, glasses, food, mustache, robot, combo1, combo2
    
    private func nextCase(_ cases: [Self]) -> Self? {
        if self == cases.last {
            return cases.first
        } else {
            return cases
                .drop(while: ) { $0 != self }
                .dropFirst()
                .first
        }
    }
    
    func next() -> Self {
        nextCase(Self.allCases) ?? .eyeball
    }
    
    func previous()  -> Self {
        nextCase(Self.allCases.reversed()) ?? .fancyHat
    }
}

struct PropChooser: View {
    
    @Binding var currentProp: Prop
    @Binding var shouldTakeSnapShot: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                currentProp = currentProp.previous()
            }) {
                Image(systemName: "chevron.left.circle.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
            }
            Spacer()
            Button(action: {
                shouldTakeSnapShot = true
            }) {
                Image(systemName: "camera.circle.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
            }
            Spacer()
            Button(action: {
                currentProp = currentProp.next()
            }) {
                Image(systemName: "chevron.right.circle.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
            }
        }
        .frame(height: 60)
        .foregroundColor(.primary)
        .padding()
        .background(BlurView(style: .light).edgesIgnoringSafeArea(.bottom))
    }
}

struct PropChooser_Previews: PreviewProvider {
    static var previews: some View {
        PropChooser(currentProp: .constant(Prop.fancyHat), shouldTakeSnapShot: .constant(false))
    }
}
