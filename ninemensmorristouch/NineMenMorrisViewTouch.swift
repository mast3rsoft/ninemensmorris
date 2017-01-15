//
//  NineMenMorrisViewTouch.swift
//  ninemensmorris
//
//  Created by Niko Neufeld on 13.01.17.
//  Copyright © 2017 pinbeutel. All rights reserved.
//

import UIKit

// in units of baseLen
let stoneCoord: [Field: [Int]] = [
    .OutTopLeft:  [0, 0],
    .OutTopMid:   [3, 0],
    .OutTopRight: [6, 0],
    .OutMidRight: [6, 3],
    .OutBotRight: [6, 6],
    .OutBotMid:   [3, 6],
    .OutBotLeft:  [0, 6],
    .OutMidLeft:  [0, 3],
    .MidTopLeft:  [1, 1],
    .MidTopMid:   [3, 1],
    .MidTopRight: [5, 1],
    .MidMidRight: [5, 3],
    .MidBotRight: [5, 5],
    .MidBotMid:   [3, 5],
    .MidBotLeft:  [1, 5],
    .MidMidLeft:  [1, 3],
    .InnTopLeft:  [2, 2],
    .InnTopMid:   [3, 2],
    .InnTopRight: [4, 2],
    .InnMidRight: [4, 3],
    .InnBotRight: [4, 4],
    .InnBotMid:   [3, 4],
    .InnBotLeft:  [2, 4],
    .InnMidLeft:  [2, 3],
]
@IBDesignable
class NineMensMorrisViewTouch: UIView {
    @IBInspectable var circleRad: CGFloat = 10.0 {
        didSet {
            self.computeCentres()
            self.setNeedsDisplay()
        }
    }
    var stoneRad: CGFloat = 25.0
    var baseLen: CGFloat = 80.0
    @IBInspectable var lineWidth: CGFloat = 5.0
    var xOff: CGFloat = 130.0
    var yOff: CGFloat = 80.0
    var centrePoint = Array(repeating: CGPoint(x: 0, y: 0), count: 24)
    var board: [Color] = Array(repeating: .Blank, count: 24) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var takenStones: [Color: Int] = [.White: 0, .Black: 0] {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var highLighted = Set<Int>() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var highLightedBlue = Set<Int>() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    func computeCentres() {
     //   centrePoint = Array(repeating: CGPoint(x: 0, y: 0), count: 24)
        for scale in [3, 2, 1] {
            for i in 0...2 {
                centrePoint[(3 - scale) * 8 + i] =
                    CGPoint(x: xOff + baseLen * CGFloat(scale * i + 3 - scale),
                            y: yOff + baseLen * CGFloat(3 - scale))
                centrePoint[(3 - scale) * 8 + 6 - i] =
                    CGPoint(x: xOff + baseLen * CGFloat(scale * i + 3 - scale),
                            y: yOff + baseLen * CGFloat(3 + scale))
            }
        }
        for i in [0, 1, 2] {
            centrePoint[8 * i + 7] =
                CGPoint(x: xOff + baseLen * CGFloat(i),
                        y: yOff + baseLen * 3.0)
            centrePoint[8 * i + 3] =
                CGPoint(x: xOff + baseLen * CGFloat(6 - i),
                        y: yOff + baseLen * 3.0)
        }
        //return centrePoint
    }
    func addCircle(_ i : Int, _ p: inout UIBezierPath) {
        p.move(to: CGPoint(x: centrePoint[i].x + circleRad, y: centrePoint[i].y))
        p.addArc(withCenter: centrePoint[i], radius: circleRad, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
    }
    func addLineSegment(_ i: Int, _ j: Int, _ p: inout UIBezierPath,
                        _ deltaX: Int = 0, _ deltaY: Int = 0) {
        p.move(to: CGPoint(x: centrePoint[i].x + CGFloat(deltaX) * circleRad,
                           y: centrePoint[i].y + CGFloat(deltaY) * circleRad))
        p.addLine(to: CGPoint(x: centrePoint[j].x - CGFloat(deltaX) * circleRad,
                           y: centrePoint[j].y - CGFloat(deltaY) * circleRad))
    }
    func drawSquare2() {
        UIColor.black.setStroke()
        for i in 0...2 {
            var p = UIBezierPath()
            p.lineWidth = lineWidth
            addCircle(8 * i + 0, &p)
            addLineSegment(8 * i + 0, 8 * i + 1, &p, 1, 0)
            addCircle(8 * i + 1, &p)
            addLineSegment(8 * i + 1, 8 * i + 2, &p, 1, 0)
            addCircle(8 * i + 2, &p)
            addLineSegment(8 * i + 2, 8 * i + 3, &p, 0, 1)
            addCircle(8 * i + 3, &p)
            addLineSegment(8 * i + 3, 8 * i + 4, &p, 0, 1)
            addCircle(8 * i + 4, &p)
            addLineSegment(8 * i + 4, 8 * i + 5, &p, -1, 0)
            addCircle(8 * i + 5, &p)
            addLineSegment(8 * i + 5, 8 * i + 6, &p, -1, 0)
            addCircle(8 * i + 6, &p)
            addLineSegment(8 * i + 6, 8 * i + 7, &p, 0, -1)
            addCircle(8 * i + 7, &p)
            addLineSegment(8 * i + 7, 8 * i + 0, &p, 0, -1)
            p.stroke()
        }
    }

    func drawCross2() {
        UIColor.black.setStroke()
        var p = UIBezierPath()
        p.lineWidth = lineWidth
        addLineSegment(1,  9, &p, 0, 1)
        addLineSegment(9, 17, &p, 0, 1)
        addLineSegment(5, 13, &p, 0, -1)
        addLineSegment(13, 21, &p, 0, -1)
        addLineSegment(7, 15, &p, 1, 0)
        addLineSegment(15, 23, &p, 1, 0)
        addLineSegment(3, 11, &p, -1, 0)
        addLineSegment(11, 19, &p, -1, 0)
        p.stroke()
    }
    func drawStone(stone: Int) {
        if board[stone] == .Blank {
            return
        }
        if board[stone] == .White {
            UIColor.white.setFill()
            UIColor.white.setStroke()
        } else {
            UIColor.black.setFill()
            UIColor.black.setStroke()
        }
        let x = centrePoint[stone].x - stoneRad
        let y = centrePoint[stone].y - stoneRad
        let p = UIBezierPath(ovalIn: CGRect(x: x, y: y,
                                            width: 2 * stoneRad, height: 2 * stoneRad))
        
        p.fill()
        p.lineWidth = lineWidth
        if highLighted.contains(stone) {
            UIColor.red.setStroke()
        }
        if highLightedBlue.contains(stone) {
            UIColor.blue.setStroke()
        }
        p.stroke()
    }
    func drawStone(_ x: CGFloat, _ y: CGFloat, _ color: Color) {
        if (color == .Black) {
            UIColor.black.setFill()
        } else {
            UIColor.white.setFill()
        }
        let p = UIBezierPath(ovalIn: CGRect(x: x, y: y,
                                            width: 2.0 * stoneRad,
                                            height: 2.0 * stoneRad))
        p.fill()
    }
    func drawStones() {
        for (i, _) in board.enumerated() {
            drawStone(stone: i)
        }
        var i = 0
        while (i < takenStones[.Black]!) {
            drawStone((10 + stoneRad), yOff + stoneRad +
                CGFloat(i) * (10.0 + 2 * stoneRad), .Black)
            i += 1
        }
        i = 0
        while (i < takenStones[.White]!) {
            drawStone(xOff + (10 + stoneRad) + 6 * baseLen,
                      yOff + stoneRad + CGFloat(i) * (10.0 + 2 * stoneRad), .White)
            i += 1
        }
    }
    override func draw(_ dirtyRect: CGRect) {
        //super.draw(dirtyRect)
        UIColor.yellow.setFill()
        UIBezierPath(rect: bounds).fill()
        self.baseLen = min(bounds.width, bounds.height) / 8.0
        stoneRad = 0.25 * baseLen
        xOff = (bounds.width - 6 * self.baseLen) / 2.0
        yOff = (bounds.height - 6 * self.baseLen) / 2.0
        self.computeCentres()
        drawSquare2()
        drawCross2()
        drawStones()
    }
    
    func tappedField(_ p: CGPoint) -> Field {
        print("Click!%f %f", p.x, p.y)
        for (i, point) in centrePoint.enumerated() {
            if abs(p.x - point.x) < stoneRad && abs(p.y - point.y) < stoneRad {
                return Field(rawValue: i)!
            }
        }
        return .OffBoard
    }
}
