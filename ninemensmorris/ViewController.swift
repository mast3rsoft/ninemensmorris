//
//  ViewController.swift
//  ninemensmorris
//
//  Created by Niko Neufeld on 9/11/16.
//  Copyright © 2016 pinbeutel. All rights reserved.
//

import Cocoa
import Dispatch

class ViewController: NSViewController {
    @IBOutlet weak var whiteLabel: NSTextField!
    @IBOutlet weak var blackMoveLabel: NSTextField!
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var whiteMoveLabel: NSTextField!
    @IBOutlet weak var blackLabel: NSTextField!
    @IBOutlet weak var gameBoard: NineMensMorrisView!
    var state: GameState = .MoveTo
    weak var model: Engine!//(player: .White)
    var lastField: Field = .OffBoard
    let queue = DispatchQueue.global(qos: .userInitiated)
    var myMove = Move(from: .OffBoard, to: .OffBoard)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        model = self.representedObject as! Engine
        gameBoard.fieldClicked = self.fieldClicked
        if model.computer == .White {
            if let computerName = Host.current().localizedName {
                whiteLabel.stringValue = computerName
            } else {
                whiteLabel.stringValue = "Computer"
            }
            blackLabel.stringValue = NSUserName() 
            computerMoveDispatch()
        } else {
            if let computerName = Host.current().localizedName {
                blackLabel.stringValue = computerName
            } else {
                blackLabel.stringValue = "Computer"
            }
            blackLabel.stringValue = NSUserName()
        }
    }
    override func viewWillAppear() {
       // model = self.representedObject as! Engine
    }
    
    @IBAction func exitFunc(_ sender: NSButton) {
        self.dismissViewController(self)
    }
    override func mouseDown(with event: NSEvent) {
        let event_location = event.locationInWindow;
        let p = gameBoard.convert(event_location, from: nil)
        NSLog("Clack!%f %f", p.x, p.y)
    }
    func computerHasMoved() {
 //       NSLog("Computer has moved %d %d", myMove.from.rawValue, myMove.to.rawValue)
        if myMove.from != .OffBoard {
            gameBoard.highLighted.insert(myMove.from.rawValue)
            usleep(100000)
            gameBoard.highLighted.remove(myMove.from.rawValue)
            gameBoard.board[myMove.from.rawValue] = .Blank
        }
        gameBoard.highLighted.insert(myMove.to.rawValue)
        usleep(100000)
        gameBoard.highLighted.remove(myMove.to.rawValue)
        gameBoard.board[myMove.to.rawValue] = model.computer
        if let takeFieldIndex = myMove.take?.rawValue {
            gameBoard.highLighted.insert(takeFieldIndex)
            usleep(100000)
            gameBoard.highLighted.remove(takeFieldIndex)
            gameBoard.takenStones[model.player]! += 1
            gameBoard.board[takeFieldIndex] = .Blank
        }
        if model.legalMoves().isEmpty {
            computerWins()
            return
        }
        if model.nMove < 18 {
            state = .MoveTo
        } else {
            state = .MoveFrom
        }
    }
    func computerWins() {
        NSLog("Computer wins! Needs implementation")
    }
    func playerWins() {
        NSLog("Player wins! Needs implementation")
    }
    func computerMoveDispatch() {
        state = .WaitForComputer
        gameBoard.highLighted.removeAll()
        queue.async {
            if let move = self.model.computerMove() {
                NSLog("Computer moves %d %d", move.from.rawValue, move.to.rawValue)
                self.myMove = move
                DispatchQueue.main.async {
                    self.computerHasMoved()
                }
            } else {
                DispatchQueue.main.async {
                    self.playerWins()
                }
            }
        }
    }
    func computerMove() {
        if let move = model.computerMove() {
            NSLog("Computer moves %d %d", move.from.rawValue, move.to.rawValue)
            gameBoard.board[move.to.rawValue] = model.computer
            if let takeField = move.take {
                NSLog("Computer takes %d", takeField.rawValue)
                gameBoard.board[takeField.rawValue] = .Blank
                gameBoard.takenStones[model.player]! += 1
            }
            if move.from != .OffBoard {
                gameBoard.board[move.from.rawValue] = .Blank
            }
            if model.legalMoves().isEmpty {
                NSLog("Game over - Computer wins - needs implementation")
            }
        } else {
            NSLog("Game over - Player wins- needs implementation")
        }
    }
    func fieldClicked(field: Field) {
        struct StaticVars {
            static var from: Field = .OffBoard
            static var to:   Field = .OffBoard
        }
        //gameBoard.board = model.board
  //      NSLog("white stones %d", model.current.stonesLeft[0])
        switch state {
        case .MoveFrom:
            for m in model.legalMoves() {
                if m.from == field {
                    gameBoard.highLighted.insert(field.rawValue)
                    state = .MoveTo
                    StaticVars.from = field
                    return
                }
            }
        case .MoveTo:
            for m in model.legalMoves() {
                if m.to == field && m.from == StaticVars.from {
                    gameBoard.highLighted.removeAll()
                    gameBoard.highLighted.insert(field.rawValue)
                    gameBoard.board[field.rawValue] = model.player
                    if m.from != .OffBoard {
                        gameBoard.board[m.from.rawValue] = .Blank
                    }
                    if m.take == nil {
                        do {
                            try model.playerMove(m)
                        } catch {
                            NSLog("Illegal move .MoveTo! Should not happen")
                            return
                        }
                        computerMoveDispatch()
                    } else {
                        StaticVars.to = field
                        state = .Take
                    }
                    return
                }
            }
        case .Take:
            for m in model.legalMoves() {
                if m.take == field && m.to == StaticVars.to {
                    gameBoard.board[field.rawValue] = .Blank
                    do {
                        try model.playerMove(m)
                    } catch {
                        NSLog("Illegal move in .Take Should not happen")
                        return
                    }
                    gameBoard.takenStones[model.computer]! += 1
                    gameBoard.highLighted.removeAll()
                    computerMoveDispatch()
                }
            }
        case .WaitForComputer:
            NSLog("Please wait...")
        }
    }
}

