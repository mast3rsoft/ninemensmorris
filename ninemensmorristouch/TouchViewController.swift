//
//  TouchViewController.swift
//  ninemensmorristouch
//
//  Created by Niko Neufeld on 13.01.17.
//  Copyright © 2017 pinbeutel. All rights reserved.
//

import UIKit
import Dispatch

class TouchViewController: UIViewController {

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  
    @IBAction func tap1(_ sender: UITapGestureRecognizer) {
        let field = board!.tappedField(sender.location(in: board))
        print(field)
        self.fieldClicked(field)
    }
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var blackLabel: UILabel!
    @IBOutlet weak var whiteLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var moveLabel: UILabel!
    @IBOutlet weak var board: NineMensMorrisViewTouch!
    var state: GameState = .MoveTo
    var model = Engine(player: .White)
    var lastField: Field = .OffBoard
    let queue = DispatchQueue.global(qos: .userInitiated)
    var myMove = Move(from: .OffBoard, to: .OffBoard)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if model.computer == .White {
            whiteLabel.text = "Computer"
            blackLabel.text = NSUserName()
            computerMoveDispatch()
        } else {
            blackLabel.text = "Computer"
            blackLabel.text = NSUserName()
        }
    }
 
//   @IBAction func exitFunc(_ sender: NSButton) {
//      self.dismissViewController(self)
//  }
 
    func computerHasMoved() {
        //       print("Computer has moved %d %d", myMove.from.rawValue, myMove.to.rawValue)
        if myMove.from != .OffBoard {
            board.highLighted.insert(myMove.from.rawValue)
            usleep(100000)
            board.highLighted.remove(myMove.from.rawValue)
            board.board[myMove.from.rawValue] = .Blank
        }
        board.highLighted.insert(myMove.to.rawValue)
        usleep(100000)
        board.highLighted.remove(myMove.to.rawValue)
        board.board[myMove.to.rawValue] = model.computer
        if let takeFieldIndex = myMove.take?.rawValue {
            board.highLighted.insert(takeFieldIndex)
            usleep(100000)
            board.highLighted.remove(takeFieldIndex)
            board.takenStones[model.player]! += 1
            board.board[takeFieldIndex] = .Blank
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
        print("Computer wins! Needs implementation")
    }
    func playerWins() {
        print("Player wins! Needs implementation")
    }
    func computerMoveDispatch() {
        state = .WaitForComputer
        board.highLighted.removeAll()
        queue.async {
            if let move = self.model.computerMove() {
                print("Computer moves %d %d", move.from.rawValue, move.to.rawValue)
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
            print("Computer moves %d %d", move.from.rawValue, move.to.rawValue)
            board.board[move.to.rawValue] = model.computer
            if let takeField = move.take {
                print("Computer takes %d", takeField.rawValue)
                board.board[takeField.rawValue] = .Blank
                board.takenStones[model.player]! += 1
            }
            if move.from != .OffBoard {
                board.board[move.from.rawValue] = .Blank
            }
            if model.legalMoves().isEmpty {
                print("Game over - Computer wins - needs implementation")
            }
        } else {
            print("Game over - Player wins- needs implementation")
        }
    }
    func fieldClicked(_ field: Field) {
        struct StaticVars {
            static var from: Field = .OffBoard
            static var to:   Field = .OffBoard
        }
        //board.board = model.board
        //      print("white stones %d", model.current.stonesLeft[0])
        switch state {
        case .MoveFrom:
            for m in model.legalMoves() {
                if m.from == field {
                    board.highLighted.insert(field.rawValue)
                    state = .MoveTo
                    StaticVars.from = field
                    return
                }
            }
        case .MoveTo:
            for m in model.legalMoves() {
                if m.to == field && m.from == StaticVars.from {
                    board.highLighted.removeAll()
                    board.highLighted.insert(field.rawValue)
                    board.board[field.rawValue] = model.player
                    if m.from != .OffBoard {
                        board.board[m.from.rawValue] = .Blank
                    }
                    if m.take == nil {
                        do {
                            try model.playerMove(m)
                        } catch {
                            print("Illegal move .MoveTo! Should not happen")
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
                    board.board[field.rawValue] = .Blank
                    do {
                        try model.playerMove(m)
                    } catch {
                        print("Illegal move in .Take Should not happen")
                        return
                    }
                    board.takenStones[model.computer]! += 1
                    board.highLighted.removeAll()
                    computerMoveDispatch()
                }
            }
        case .WaitForComputer:
            print("Please wait...")
        }
    }

}

