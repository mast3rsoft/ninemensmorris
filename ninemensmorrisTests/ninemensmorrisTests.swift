//
//  ninemensmorrisTests.swift
//  ninemensmorrisTests
//
//  Created by Niko Neufeld on 9/11/16.
//  Copyright © 2016 pinbeutel. All rights reserved.
//

import XCTest
@testable import ninemensmorris

class ninemensmorrisTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let engine = Engine(player: .White)
        let move = Move(from: Field.OffBoard, to: Field.MidTopMid)
        engine.applyMove(move: move, player: Color.White)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    // true if two sequences contain the same elements in any order, i.e. any element in s1 is in s2 and any in s2 in s1
    // this is slow i.e. O(2nm)
    func compareElementsNoOrder<S: Sequence>(_ s1: S, _ s2: S, by equals: (S.Iterator.Element, S.Iterator.Element) -> Bool)->Bool {
        for e1 in s1 {
            var found = false
            for e2 in s2 {
                if equals(e2, e1) {
                    found = true;
                    break;
                }
            }
            if !found {
                return false
            }
        }
        // reverse check could be avoided by copying and eating s1
        for e2 in s2 {
            var found = false
            for e1 in s1 {
                if equals(e1, e2) {
                    found = true;
                    break;
                }
            }
            if !found {
                return false
            }
        }
        return true
    }
    func testApplyMove() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let engine = Engine(player: .White)
        let move = Move(from: Field.OffBoard, to: Field.MidTopMid)
        engine.applyMove(move: move, player: Color.White)
        XCTAssertEqual(engine.board[9], Color.White, "Put to top middle 4-way failed")
        engine.applyMove(move: Move(from: Field.MidTopMid, to: Field.MidTopRight), player: Color.White)
        XCTAssertEqual(engine.board[10], Color.White, "Move by 1 failed")
    }
    func testUndoMove() {
        let engine = Engine()
        engine.board = [ Color.Black, Color.Black, Color.Black, Color.Blank, Color.White, Color.White ]
            + Array(repeating: Color.Blank, count: 18)
        engine.applyMove(move: Move(from: Field.OffBoard, to: Field.OutBotLeft, take: Field.OutTopLeft), player: Color.White)
        engine.undoMove(move: Move(from: Field.OffBoard, to: Field.OutBotLeft, take: Field.OutTopLeft), player: Color.White)
        XCTAssertEqual(engine.board, [ Color.Black, Color.Black, Color.Black, Color.Blank, Color.White, Color.White ]
            + Array(repeating: Color.Blank, count: 18), "Undo move failed")
    }
    func testCheckThreeInARow() {
        let engine = Engine()
        engine.board = [ Color.Black, Color.Black, Color.Black, Color.Blank, Color.White, Color.White ]
            + Array(repeating: Color.Blank, count: 18)
        XCTAssertTrue(engine.isThreeInRow(field: Field.OutTopMid, color: Color.Black))
        XCTAssertFalse(engine.isThreeInRow(field: Field.InnBotMid, color: Color.White))
    }
    func testExpandMoves() {
        let engine = Engine()
        // outer ring fully white except first field, middle ring black except on the middle right,
        // middle right (black)
        engine.board = [Color.Blank, Color.Blank]
        engine.board += Array(repeating: Color.White, count: 6) + Array(repeating: Color.Black, count: 6) + Array(repeating: Color.Blank, count: 10)
        // engine.board = Array(repeating: Color.White, count: 8) + Array(repeating: Color.Black, count: 7) +
        // Array(repeating: Color.Blank, count: 8) + [Color.Black] // <-- seems to be illegal
        let p = Position(move: Move(from: Field.OffBoard, to: Field.MidTopMid))
        p.nMoves = 12
        p.stonesLeft = [9, 9]
        engine.expand(position: p)
        XCTAssert(p.nextPos.count == 12, "expansion failed should have only 12 moves")
        
    }
    func testFieldsToMoveTo() {
        let engine = Engine()
        engine.board = [ .Blank, .Blank, .Blank, .White, .Blank, .Blank, .Blank, .Black,
                         .Blank, .White, .Black, .White, .Blank, .White, .Black, .White,
                         .Black, .Black, .Blank, .White, .Blank, .White, .Black, .White]
        XCTAssertEqual(engine.fieldsToMoveTo(), [11, 3])
    }
    // difference in stones 1, differences in free stones 8, difference in two-in-a-row 0
    func testScore() {
        let engine = Engine()
        engine.board = [ .Blank, .Blank, .Blank, .White, .Blank, .Blank, .Blank, .Black,
                         .Blank, .White, .Black, .White, .Blank, .White, .Black, .White,
                         .Black, .Black, .Blank, .White, .Blank, .White, .Black, .White]
        let p = Position(move: Move(from: Field.InnTopRight, to: Field.InnMidRight, take: Field.OutTopLeft))
        p.stonesLeft = [ 7, 6]
        p.nMoves = 31
        XCTAssertEqual(engine.score(position: p), 140, "Score mismatch")
    }
    func testEvaluate() {
        let engine = Engine()
        engine.board = [ .Blank, .Blank, .Blank, .Blank, .Blank, .Blank, .Blank, .Blank,
                         .Blank, .White, .Blank, .Black, .Blank, .Blank, .Blank, .Blank,
                         .Blank, .Blank, .Blank, .Blank, .Blank, .Blank, .Blank, .Blank]
        let p = Position(move: Move(from: Field.InnTopRight, to: Field.InnMidRight, take: Field.OutTopLeft))
        p.stonesLeft = [ 9, 9]
        p.nMoves = 2
        var nPos = 0
        let (_, _) = engine.evaluate(p: p, player: Color.White, depth: 0, nPos: &nPos, maxDepth: 2, maxPos: 1000)
        XCTAssertEqual(nPos, 22 + 22 * 21, "Number of Positions")
    }
    func testExpand2() {
        let engine = Engine(player: .White)
        engine.board = [ .Black, .White, .Black, .Black, .Black, .White, .Black, .Black,
                         .White, .White, .Blank, .Black, .Black, .White, .Black, .White,
                         .Blank, .Blank, .Blank, .White, .White, .Blank, .Blank, .Blank ]
        let p = Position(move: Move(from: Field.MidTopRight, to: Field.MidMidRight))
        p.stonesLeft = [ 8, 9]
        p.nMoves = 30
        engine.expand(position: p)
        //                                                                  moves for black
        let moves = [Move(from: Field.MidTopMid, to: Field.MidTopRight), // 0
                     Move(from: Field.MidTopMid, to: Field.InnTopMid),   // 1
                     Move(from: Field.InnMidRight, to: Field.InnTopRight), // 2
                     Move(from: Field.InnBotRight, to: Field.InnBotMid, take: Field.MidBotLeft), // 1
                     Move(from: Field.InnBotRight, to: Field.InnBotMid, take: Field.MidBotRight), // 2
                     Move(from: Field.InnBotRight, to: Field.InnBotMid, take: Field.MidMidRight), // 2
                     Move(from: Field.MidBotMid, to: Field.InnBotMid),    // 3
                     Move(from: Field.MidMidLeft, to: Field.InnMidLeft)]  // 3
        XCTAssertEqual(p.nextMove.count, moves.count, "Number of moves")
        XCTAssert(compareElementsNoOrder(moves, p.nextMove, by: { (m1: Move, m2: Move) -> Bool in
                            return (m1.to == m2.to) && (m1.from == m2.from) &&
                                (m1.take == m2.take) }))
    }
    // 
    func testEvaluate2() {
        let engine = Engine()
        engine.board = [ .Black, .White, .Black, .Black, .Black, .White, .Black, .Black,
                         .White, .White, .Blank, .Black, .Black, .White, .Black, .White,
                         .Blank, .Blank, .Blank, .White, .White, .Blank, .Blank, .Blank ]
        let p = Position(move: Move(from: Field.MidTopRight, to: Field.MidMidRight))
        p.stonesLeft = [ 8, 9]
        p.nMoves = 30
        var nPos = 0
        var (score, move) = engine.evaluate(p: p, player: .White, depth: 2, nPos: &nPos, maxDepth: 4, maxPos: 100)
        XCTAssertEqual(score, engine.maxScore)
        XCTAssert((move!.to == .MidTopRight) && (move!.from == .MidTopMid))
        XCTAssertEqual(nPos, 22)
        print("Evaluated \(nPos) positions")
        nPos = 0
        (score, move) = engine.evaluate(p: p, player: .White, depth: 2, nPos: &nPos, maxDepth: 6, maxPos: 100)
        XCTAssert((move!.to == .MidTopRight) && (move!.from == .MidTopMid))
        print("Evaluated \(nPos) positions")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    func testTest() {
        let t = Test()
        XCTAssertEqual(1, t.b)
    }
    func testEvaluateMove2() {
        let engine = Engine()
        do {
            try engine.playerMove(Move(from: .OffBoard, to: .MidTopMid))
            _ = engine.computerMove()
            try engine.playerMove(Move(from: .OffBoard, to: .MidTopLeft))
            _ = engine.computerMove()
        } catch {
            NSLog("couldn't move")
        }
        XCTAssert(engine.legalMoves().count == 20)
        
    }
    // recognize simple three-in-a-row threat
    // requires calculation to depth 3 
    func testSimpleDefense() {
        let engine = Engine()
        do {
            try engine.playerMove(Move(from: .OffBoard, to: .OutBotLeft))
            _ = engine.computerMove()
            try engine.playerMove(Move(from: .OffBoard, to: .OutBotMid))
        } catch {
           NSLog("Illegal player move!")
        }
        engine.maxDepth = 3
        if let move = engine.computerMove() {
            XCTAssert(move.to == .OutBotRight)
        } else {
            XCTFail()
        }
    }
    func testDetectDoubleThreat() {
        let engine = Engine()
        engine.board = [ .Blank, .Blank, .Blank, .Blank, .Blank, .Blank, .Blank, .Blank,
                         .Blank, .Blank, .Blank, .Black, .Blank, .White, .Blank, .White,
                         .Blank, .Blank, .Blank, .Blank, .Blank, .Blank, .Blank, .Blank ]
        let p = Position(move: Move(from: Field.OffBoard, to: Field.MidMidLeft))
        p.nMoves = 3
        p.stonesLeft = [9, 9]
        engine.current = p
        engine.maxDepth = 3
        let move = engine.computerMove()!
        let correctMoves: [Field] = [.MidBotLeft, .MidBotRight, .InnMidRight, .OutMidRight, .MidTopRight]
        XCTAssert(correctMoves.contains(move.to))

    }
}

