//
//  Grid.swift
//  NumberMerge
//
//  Created by FanRende on 2022/4/24.
//

import SwiftUI

struct Grid: Identifiable {
    let id = UUID()
    var number: Int
    var image: String
    var color: Color
    
    init(_ i: Int = 0) {
        self.number = i
        self.image = Grid.imageList[i > 0 ? i-1 : 0]
        self.color = Grid.colorList[i]
    }
    
    func isEmpty() -> Bool {
        return self.number == 0
    }
}

extension Grid {
    static let background = Grid(7)
    static let typeNumber: Int = 6
    static let imageList: Array<String> = Array(1...11).map { "\($0)" }
    static let colorList: Array<Color> = [.clear, .purple, .blue, .green, .yellow, .orange, .red, .secondary]
}

struct GridView: View {
    let grid: Grid

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            grid.color

            if grid.number > 0 && grid.number <= Grid.typeNumber {
                Image("\(grid.image)")
                    .resizable()
                    .scaledToFit()
                StrokeText(text: "\(grid.number)")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))
                    .padding(2)
            }
        }
        .frame(width: 50, height: 50)
        .cornerRadius(5)
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(grid: Grid(1))
    }
}

struct StrokeText: View {
    let text: String

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  1, y:  1)
                Text(text).offset(x: -1, y: -1)
                Text(text).offset(x: -1, y:  1)
                Text(text).offset(x:  1, y: -1)
            }
            .foregroundColor(.black)
            Text(text)
        }
    }
}
