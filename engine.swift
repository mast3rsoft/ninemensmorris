//
//  engine.swift
//  ninemensmorris
//
//  Created by Niko Neufeld on 9/11/16.
//  Copyright © 2016 pinbeutel. All rights reserved.
//

import Foundation

//      0-------1-------2
//      |       |       |
//      | 8-----9----10 |
//      | |     |     | |
//      | |  16-17-18 | |
//      | |  |      | | |
//      7-15-23    19-11-3
//      | |  |      | | |
//      | |  22-21-20 | |
//      | |     |     | |
//      | 14----13---12 |
//      |       |       |
//      6-------5-------4
enum GameState {
    case MoveFrom, MoveTo, Take, WaitForComputer, GameOver
}

enum NineMenMorrisError: Error {
    case noSuchMove
}

enum Color: Int {
    case Blank = -1, White = 0, Black = 1
}

enum Field: Int {
    case OffBoard = -1,
                    OutTopLeft  = 0, OutTopMid, OutTopRight, //
                    OutMidRight, OutBotRight, OutBotMid,     //
                    OutBotLeft, OutMidLeft,                  //
                    MidTopLeft, MidTopMid, MidTopRight,      //
                    MidMidRight, MidBotRight, MidBotMid,     //
                    MidBotLeft, MidMidLeft,                  //
                    InnTopLeft, InnTopMid, InnTopRight,      //
                    InnMidRight, InnBotRight, InnBotMid,     //
                    InnBotLeft, InnMidLeft                   //
}

let neighbour = [ [Field.OutMidLeft, Field.OutTopMid],
                  [Field.OutTopLeft, Field.OutTopRight, Field.MidTopMid],
                  [Field.OutTopMid, Field.OutMidRight],
                  [Field.OutTopRight, Field.OutBotRight, Field.MidMidRight],
                  [Field.OutMidRight, Field.OutBotMid],
                  [Field.MidBotMid, Field.OutBotRight, Field.OutBotLeft],
                  [Field.OutBotMid, Field.OutMidLeft],
                  [Field.OutBotLeft, Field.MidMidLeft, Field.OutTopLeft],
                  [Field.MidMidLeft, Field.MidTopMid],
                  [Field.MidTopLeft, Field.MidTopRight, Field.OutTopMid, Field.InnTopMid],
                  [Field.MidTopMid, Field.MidMidRight],
                  [Field.MidTopRight, Field.MidBotRight, Field.OutMidRight, Field.InnMidRight ],
                  [Field.MidMidRight, Field.MidBotMid],
                  [Field.MidBotRight, Field.MidBotLeft, Field.OutBotMid, Field.InnBotMid ],
                  [Field.MidBotMid, Field.MidMidLeft],
                  [Field.MidBotLeft, Field.MidTopLeft, Field.OutMidLeft, Field.InnMidLeft],
                  [Field.InnTopMid, Field.InnMidLeft],
                  [Field.InnTopLeft, Field.InnTopRight, Field.MidTopMid],
                  [Field.InnTopMid, Field.InnMidRight],
                  [Field.InnTopRight, Field.InnBotRight, Field.MidMidRight],
                  [Field.InnMidRight, Field.InnBotMid],
                  [Field.InnBotRight, Field.InnBotLeft, Field.MidBotMid],
                  [Field.InnBotMid, Field.InnMidLeft],
                  [Field.InnBotLeft, Field.InnTopLeft, Field.MidMidLeft]]

let threeInRow: [Field: [[Field]]] = [
    .OutTopLeft:  [[.OutTopMid, .OutTopRight], [.OutBotLeft, .OutMidLeft]],
    .OutTopMid:   [[.OutTopLeft, .OutTopRight], [.MidTopMid, .InnTopMid]],
    .OutTopRight: [[.OutTopLeft, .OutTopMid], [.OutMidRight, .OutBotRight]],
    .OutMidRight: [[.OutTopRight, .OutBotRight], [.MidMidRight, .InnMidRight]],
    .OutBotRight: [[.OutTopRight, .OutMidRight], [.OutBotMid, .OutBotLeft]],
    .OutBotMid:   [[.OutBotRight, .OutBotLeft], [.MidBotMid, .InnBotMid]],
    .OutBotLeft:  [[.OutMidLeft, .OutTopLeft], [.OutBotMid, .OutBotRight]],
    .OutMidLeft:  [[.OutBotLeft, .OutTopLeft], [.MidMidLeft, .InnMidLeft]],
    .MidTopLeft:  [[.MidTopMid, .MidTopRight], [.MidBotLeft, .MidMidLeft]],
    .MidTopMid:   [[.MidTopLeft, .MidTopRight], [.OutTopMid, .InnTopMid]],
    .MidTopRight: [[.MidTopLeft, .MidTopMid], [.MidMidRight, .MidBotRight]],
    .MidMidRight: [[.MidTopRight, .MidBotRight], [.OutMidRight, .InnMidRight]],
    .MidBotRight: [[.MidTopRight, .MidMidRight], [.MidBotMid, .MidBotLeft]],
    .MidBotMid:   [[.MidBotRight, .MidBotLeft], [.InnBotMid, .OutBotMid]],
    .MidBotLeft:  [[.MidMidLeft, .MidTopLeft], [.MidBotMid, .MidBotRight]],
    .MidMidLeft:  [[.MidBotLeft, .MidTopLeft], [.OutMidLeft, .InnMidLeft]],
    .InnTopLeft:  [[.InnTopMid, .InnTopRight], [.InnBotLeft, .InnMidLeft]],
    .InnTopMid:   [[.InnTopLeft, .InnTopRight], [.MidTopMid, .OutTopMid]],
    .InnTopRight: [[.InnTopLeft, .InnTopMid], [.InnMidRight, .InnBotRight]],
    .InnMidRight: [[.InnTopRight, .InnBotRight], [.MidMidRight, .OutMidRight]],
    .InnBotRight: [[.InnTopRight, .InnMidRight], [.InnBotMid, .InnBotLeft]],
    .InnBotMid:   [[.InnBotRight, .InnBotLeft], [.OutBotMid, .MidBotMid]],
    .InnBotLeft:  [[.InnMidLeft, .InnTopLeft], [.InnBotMid, .InnBotRight]],
    .InnMidLeft:  [[.InnBotLeft, .InnTopLeft], [.MidMidLeft, .OutMidLeft]]
]

class Move {
    let from: Field
    let to: Field
    let take: Field?
    init (from: Field = Field.OffBoard, to: Field, take: Field? = nil) {
        self.from = from
        self.to = to
        self.take = take
    }
}

class Position {
    let move: Move
    var value = 0
    var nextMove = [Move]() // could remove here and make local
    var nextPos = [Position]()
    var same: Position?
    var parent: Position?
    var stonesLeft = [ 0, 0 ]
    var nMoves: UInt32 = 0  // number of moves played (made of two half-moves)
    init (move: Move) {
        self.move = move
    }
    init (move: Move, old: Position, player: Color) {
        parent = old
        self.move = move
        nMoves = old.nMoves + 1
        stonesLeft[0] = old.stonesLeft[0] - ((move.take != nil && player == Color.Black) ? 1 : 0)
        stonesLeft[1] = old.stonesLeft[1] - ((move.take != nil && player == Color.White) ? 1 : 0)
    }
}

class Engine {
    let maxScore = 10000
    var computer: Color = .Black
    var player: Color = .White {
        didSet {
            computer = (self.player == .Black) ? .White : .Black
        }
    }
    var maxDepth = 3
    var board = Array(repeating: Color.Blank, count: 24)
    var root = Position(move: Move(from: .OffBoard, to: .OffBoard))
    var current = Position(move: Move(from: .OffBoard, to: .OffBoard))
    init(player: Color = .White) {
        startGame(player: player)
    }
    func undoLastPlayerMove() {
        if current.parent != nil {
            undoMove(move: current.move, player: computer)
            current = current.parent!
        }
        if current.parent != nil {
            undoMove(move: current.move, player: player)
            current = current.parent!
        }
    }
    func equalMoves(_ m1: Move, _ m2: Move) -> Bool {
        return (m1.from == m2.from) && (m1.to == m2.to) && (m1.take == m2.take)
    }
    func startGame(player: Color) {
        self.player = player
        self.board = Array(repeating: .Blank, count: 24)
        self.root = Position(move: Move(from: .OffBoard, to: .OffBoard))
        self.root.nMoves = 0
        self.root.stonesLeft = [9, 9]
        self.current = self.root
    }
    func legalMoves() -> [Move] {
        if current.nextPos.isEmpty {
            expand(position: current)
        }
        var moves = [Move]()
        for p in current.nextPos {
            moves.append(p.move)
        }
        return moves
    }
    func playerMove(_ move: Move) throws {
        if current.nextPos.isEmpty {
            expand(position: current)
        }
        for p in current.nextPos {
            if equalMoves(p.move, move) {
                current = p
                applyMove(move: move, player: player)
                return
            }
        }
        throw NineMenMorrisError.noSuchMove
    }
    func computerMove() -> Move? {
        var n = 0
        let (_, move) = evaluate(p: current, player: computer, depth: 0,
                                  nPos: &n, maxDepth: self.maxDepth, maxPos: 20000)
        if move == nil {
            return nil
        }
        for p in current.nextPos {
            if equalMoves(p.move, move!) {
                current = p
                applyMove(move: move!, player: computer)
            }
        }
        return move
    }
    var nMove: UInt32 {
        get {
            return current.nMoves
        }
    }
    
    func colorOf(_ field: Field) -> Color {
        return board[field.rawValue]
    }
    func expand(position: Position) {
        let player = (position.nMoves & 1 == 1) ? Color.Black : Color.White
        // generate all possible moves
        if position.nMoves < 18 {
            for (i, field) in self.board.enumerated() {
                if field == .Blank {
                    let move = Move(from: Field.OffBoard, to: Field(rawValue: i)!)
                    applyMove(move: move, player: player)
                    if isThreeInRow(field: move.to, color: player) {
                        position.nextMove += takeMoves(move: move, player: player)
                    } else {
                        position.nextMove.append(move)
                    }
                    undoMove(move: move, player: player) // undo move
                }
            }
        } else if position.stonesLeft[player.rawValue] > 3 {
            for (i, field) in self.board.enumerated() {
                if field == player {
                    for neigh in neighbour[i] {
                        if self.board[neigh.rawValue] == Color.Blank {
                            let move = Move(from: Field(rawValue: i)!, to: neigh)
                            applyMove(move: move, player: player) // check needs up-to-date board!
                            if isThreeInRow(field: move.to, color: player) {
                                position.nextMove += takeMoves(move: move, player: player)
                            } else {
                                position.nextMove.append(move)
                            }
                            undoMove(move: move, player: player) // undo move
                        }
                    }
                }
            }
        } else {
            // player can jump
            for i in 0...23 {
                if self.board[i] == player {
                    for j in 0...23 {
                        if self.board[j] == Color.Blank {
                            let move = Move(from: Field(rawValue: i)!, to: Field(rawValue: j)!)
                            applyMove(move: move, player: player)
                            if isThreeInRow(field: move.to, color: player) {
                                position.nextMove += takeMoves(move: move, player: player)
                            } else {
                                position.nextMove.append(move)
                            }
                            undoMove(move: move, player: player) // undo move
                        }
                    }
                }
            }
        }
        for move in position.nextMove {
            position.nextPos.append(Position(move: move, old: position, player: player))
        }
    }
    
    func isThreeInRow(field: Field, color: Color) -> Bool {
        for triple in threeInRow[field]! {
            if board[field.rawValue] == color &&
                board[triple[0].rawValue] == color &&
                board[triple[1].rawValue] == color {
                return true
            }
        }
        return false
    }

    func takeMoves(move: Move, player: Color) -> [Move] {
        var result = [Move]()
        
        for (i, field) in board.enumerated() {
            if field == Color.Blank {
                continue
            }
            if field != player && !isThreeInRow(field: Field(rawValue: i)!, color: board[i]) {
                result.append(Move(from: move.from, to: move.to, take: Field(rawValue: i)!))
            }
        }
        if !result.isEmpty {
            return result
        }
        for (i, field) in board.enumerated() {
            if field == Color.Blank {
                continue
            }
            if field != player {
                result.append(Move(from: move.from, to: move.to, take: Field(rawValue: i)!))
            }
        }
        return result
    }
    
    func fieldsToMoveTo() -> [Int] {
        var freeFields = [0, 0]
        for (i, field) in board.enumerated() {
            if field == .Blank { continue }
            for neigh in neighbour[i] {
                if board[neigh.rawValue] == .Blank {
                    freeFields[field.rawValue] += 1
                }
            }
        }
        return freeFields
    }
    
    // return true if game is over
    // assign value to position if not set
    func gameOver(_ p: Position) -> Bool {
        if p.stonesLeft[Color.White.rawValue] < 3 && p.nMoves >= 17 {
            p.value = -maxScore // Black wins
            return true
        }
        if p.stonesLeft[Color.Black.rawValue] < 3 && p.nMoves >= 18 {
            p.value = maxScore // White wins
            return true
        }
        let freeFields = fieldsToMoveTo()
        if freeFields[Color.Black.rawValue] == 0 &&
            p.stonesLeft[Color.Black.rawValue] > 3 &&
            p.nMoves > 18 {
                p.value = maxScore // White wins
                return true
        }
        if freeFields[Color.White.rawValue] == 0 &&
            p.stonesLeft[Color.White.rawValue] > 3 &&
            p.nMoves > 17 {
                p.value = -maxScore // Black wins
                return true
        }
        return false
    }
    // assign a score to a position
    // positive numbers for white
    // negative numbers for black
    // 0 free positions or less than 3 stones (game over) 1000
    // difference in stones x 20
    // difference in free positions x 10
    // two in a row + third free x 5
    func score(position p: Position) -> Int {
        var score = 0
        if abs(p.value) == maxScore {
            return score
        }
        let freeFields = fieldsToMoveTo()
        var twoInARow = [0, 0]
        for (field, neighbours) in threeInRow {
            if board[field.rawValue] == .Blank {
                for neigh in neighbours {
                    if board[neigh[0].rawValue] == board[neigh[1].rawValue] &&
                        board[neigh[0].rawValue] != .Blank {
                        twoInARow[board[neigh[0].rawValue].rawValue] += 1
                    }
                }
            }
        }
        if p.nMoves < 18 {
            score = 50 * (p.stonesLeft[Color.White.rawValue] - p.stonesLeft[Color.Black.rawValue]) +
                20 * (twoInARow[Color.White.rawValue] - twoInARow[Color.Black.rawValue] )

        } else {
            // missing correct treatment for jumping
            score = 40 * (p.stonesLeft[Color.White.rawValue] - p.stonesLeft[Color.Black.rawValue]) +
                10 * (freeFields[Color.White.rawValue] - freeFields[Color.Black.rawValue]) +
                10 * (twoInARow[Color.White.rawValue] - twoInARow[Color.Black.rawValue] )
        }
        for field: Field in [.MidTopMid, .MidMidLeft, .MidBotMid, .MidMidRight] {
            if board[field.rawValue] == .Black {
                if p.nMoves < 18 {
                    score += -20
                } else {
                    score += -5
                }
            }
            if board[field.rawValue] == .White {
                if p.nMoves < 18 {
                    score += 20
                } else {
                    score += 5
                }
            }
        }
        return score
    }
    
    func applyMove(move: Move, player: Color) {
        board[move.to.rawValue] = player
        if move.from != .OffBoard {
            board[move.from.rawValue] = .Blank
        }
        if move.take != nil {
            board[move.take!.rawValue] = .Blank
        }
    }
    func undoMove(move: Move, player: Color) {
        board[move.to.rawValue] = Color.Blank
        if move.from != .OffBoard {
            board[move.from.rawValue] = player
        }
        if move.take != nil {
            board[move.take!.rawValue] =
                (player == Color.Black) ? Color.White : Color.Black
        }
    }
    // evaluate:
    // get the value of a position using min/max depth first
    // use a cutoff in terms of evaluated positions or depth whichever comes
    // first
    // player is the player who is about to move
    func evaluate(p: Position, player: Color, depth: Int, nPos: inout Int,
                  maxDepth: Int, maxPos: Int) -> (Int, Move?) {
        let opponent =  (player == Color.Black) ? Color.White : Color.Black
        if gameOver(p) {
            return (p.value, nil)
        }
        if nPos > maxPos || depth >= maxDepth {
            if p.value == 0 {
                p.value = score(position: p)
            }
            return (p.value, nil)
        }
        if p.nextMove.isEmpty {
            expand(position: p)
            nPos += p.nextMove.count
        }
        var bestMove: Move?
        if player == Color.White {
            var max = -maxScore
            for nextPos in p.nextPos {
                applyMove(move: nextPos.move, player: player)
                let (val, _) = evaluate(p: nextPos, player: opponent, depth: depth + 1,
                            nPos: &nPos, maxDepth: maxDepth, maxPos: maxPos)
                //NSLog("white %d %d", nextPos.move.to.rawValue, val)
                if val >= max {
                    max = val
                    bestMove = nextPos.move
                }
                undoMove(move: nextPos.move, player: player)
            }
            p.value = max
            return (max, bestMove)
        } else {
            var min = maxScore
            for nextPos in p.nextPos {
               // NSLog("Player black to move to %d", nextPos.move.to.rawValue)
                applyMove(move: nextPos.move, player: player)
                let (val, _) = evaluate(p: nextPos, player: opponent, depth: depth + 1,
                                   nPos: &nPos, maxDepth: maxDepth, maxPos: maxPos)
               // NSLog("black %d %d", nextPos.move.to.rawValue, val)
                if val <= min {
                    min = val
                    bestMove = nextPos.move
                }
                undoMove(move: nextPos.move, player: player)
            }
            p.value = min
            return (min, bestMove)
        }
    }
    
}

