//
//  ContentView.swift
//  funnyface
//
//  Created by Hieu C Trac on 3/6/21.
//

import SwiftUI

struct ContentView : View {
    
    @State var currentProp: Prop = .robot
    @State var shouldTakeSnapShot: Bool = false
    
    var body: some View {        
        ZStack(alignment: .bottom) {
            ARViewContainer(currentProp: $currentProp, shouldTakeSnapShot: $shouldTakeSnapShot).edgesIgnoringSafeArea(.all)
            PropChooser(currentProp: $currentProp, shouldTakeSnapShot: $shouldTakeSnapShot)
        }
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
