//
//  Game.swift
//  NumberMerge
//
//  Created by FanRende on 2022/4/24.
//

import SwiftUI

struct Game {
    var board: Array<Grid> = [Grid]()
    var offset: Array<CGSize> = Array(repeating: CGSize.zero, count: Game.size)
    var nextItem: Grid = Grid(Int.random(in: 1...3))
    var disable: Bool = false
    var gameOver: Bool = false
    var score: Int = 0
    
    init() {
        for _ in 0 ..< Game.size {
            self.board.append(Grid())
        }
    }
    
    func isFull() -> Bool {
        for grid in board {
            if grid.number == 0 {
                return false
            }
        }
        return true
    }
}

extension Game {
    static let row: Int = 5
    static let column: Int = 5
    static let size: Int = 25
    static let offsetType: Array<CGSize>  = [
        CGSize(width:   0, height:  58),
        CGSize(width:   0, height: -58),
        CGSize(width:  58, height:   0),
        CGSize(width: -58, height:   0),
    ]

    enum DIRECTION: Int, CaseIterable {
        case TOP = -5, BOTTOM = 5, LEFT = -1, RIGHT = 1
    }
}

struct GameView: View {
    @AppStorage("bestRecord") var bestRecord: Int = 0
    @StateObject var game = GameViewModel()

    var body: some View {
        VStack {
            TitleView()

            Spacer()

            VStack {
                BoardView(game: game)
                MenuView(game: game)
            }
            .padding()
            .background(Color(red: 0.89, green: 0.86, blue: 0.79))
            .cornerRadius(20)
            .padding()

            Spacer()
        }
        .background(Color(red: 0.99, green: 0.96, blue: 0.89).ignoresSafeArea())
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}

class GameViewModel: ObservableObject {
    @Published var property = Game()
    
    func restart() {
        self.property = Game()
    }

    func setNextItem() {
        self.property.nextItem = Grid(Int.random(in: 1...3))
    }

    func laydown(_ idx: Int, item: Grid) -> Bool {
        if self.property.board[idx].number != 0 {
            return false
        }

        self.property.disable = true

        self.property.board[idx] = item
        
        if item.number < Grid.typeNumber {
            self.judge(idx)
        }
        else {
            self.property.disable = false
        }
        
        return true
    }

    func judge(_ idx: Int) {
        var toMerge = false
        var target = idx
        var mergeList = [Int]()
        let number = self.property.board[idx].number
        
        func isValid(dir: Game.DIRECTION, idx: Int, target: Int) -> Bool {
            if target < 0 || target >= Game.size {
                return false
            }
            
            if (dir == .LEFT || dir == .RIGHT)
                && abs(idx % Game.column - target % Game.column) != 1 {
                return false
            }
            
            return true
        }

        for (i, dir) in Game.DIRECTION.allCases.enumerated() {
            target = idx + dir.rawValue

            if isValid(dir: dir, idx: idx, target: target)
                && self.property.board[target].number == number {
                toMerge = true
                self.property.offset[target] = Game.offsetType[i]
                mergeList.append(target)
            }
        }
        
        if toMerge {
            self.property.score += 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                for target in mergeList {
                    self.property.board[target] = Grid()
                    self.property.offset[target] = CGSize.zero
                }
                self.property.board[idx] = Grid()
                self.laydown(idx, item: Grid(number + 1))
            }
        }
        else {
            self.property.disable = false

            if self.property.isFull() {
                self.property.gameOver = true
            }
        }
    }
}

struct TitleView: View {
    @AppStorage("bestRecord") var bestRecord: Int = 0

    var body: some View {
        Image("cat")
            .resizable()
            .scaledToFit()
            .frame(height: 120)
            .overlay {
                Group {
                    Text("KITTY  MERGE")
                        .font(.custom("Zapfino", size: 20))
                        .offset(y: 85)
                    Text("Best Record: \(bestRecord)")
                        .font(.caption)
                        .offset(y: 105)
                }
            }
        .padding(.vertical, 30)
    }
}

struct BoardView: View {
    @AppStorage("bestRecord") var bestRecord: Int = 0
    @ObservedObject var game: GameViewModel

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(minimum: 0, maximum: 50)), count: Game.column)

        LazyVGrid(columns: columns) {
            ForEach(Array(game.property.board.enumerated()), id: \.element.id) { idx, grid in
                GridView(grid: Grid.background)
                    .overlay {
                        GridView(grid: grid)
                            .offset(game.property.offset[idx])
                            .animation(.easeIn(duration: 0.3), value: game.property.offset[idx])
                    }
                    .onTapGesture {
                        if game.laydown(idx, item: game.property.nextItem) {
                            game.setNextItem()
                        }
                    }
            }
        }
        .disabled(game.property.gameOver || game.property.disable)
        .alert((game.property.score > bestRecord) ? "Break the Record!" : "Game Over!", isPresented: $game.property.gameOver) {
            Button("OK") {
                if game.property.score > bestRecord {
                    bestRecord = game.property.score
                }
                game.restart()
            }
        } message: {
            Text("Your Score:\n\(game.property.score)")
        }
    }
}

struct MenuView: View {
    @ObservedObject var game: GameViewModel

    var body: some View {
        HStack(alignment: .top) {
            Restart(game: game)
            Spacer()
            Score(score: game.property.score)
            Spacer()
            NextItem(item: game.property.nextItem)
        }
        .padding([.top, .horizontal])
    }
}

struct Restart: View {
    @ObservedObject var game: GameViewModel

    var body: some View {
        VStack {
            Text("Restart")
                .font(.caption)
            Button {
                game.restart()
            } label: {
                Image(systemName: "arrow.counterclockwise.circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color(red: 0.99, green: 0.96, blue: 0.89))
                    .padding(2)
                    .background(Color.secondary)
                    .clipShape(Circle())
                    .frame(width: 50, height: 50)
            }
        }
    }
}

struct Score: View {
    let score: Int

    var body: some View {
        VStack {
            Text("Score")
                .font(.caption)
            StrokeText(text: "\(score)")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(Color(red: 0.99, green: 0.96, blue: 0.89))
        }
    }
}

struct NextItem: View {
    let item: Grid

    var body: some View {
        VStack {
            Text("Next")
                .font(.caption)

            GridView(grid: item)
                .padding(5)
                .overlay {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(.secondary)
                }
        }
    }
}
