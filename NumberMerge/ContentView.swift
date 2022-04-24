//
//  ContentView.swift
//  NumberMerge
//
//  Created by FanRende on 2022/4/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GameView()
            .preferredColorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
