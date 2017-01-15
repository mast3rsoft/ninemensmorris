//
//  NineMensMorrisView.swift
//  ninemensmorris
//
//  Created by Niko Neufeld on 30/12/16.
//  Copyright © 2016 pinbeutel. All rights reserved.
//

import Cocoa

// in units of baseLen
let stoneCoord: [Field: [Int]] = [
    .OutTopLeft:  [0, 6],
    .OutTopMid:   [3, 6],
    .OutTopRight: [6, 6],
    .OutMidRight: [6, 3],
    .OutBotRight: [6, 0],
    .OutBotMid:   [3, 0],
    .OutBotLeft:  [0, 0],
    .OutMidLeft:  [0, 3],
    .MidTopLeft:  [1, 5],
    .MidTopMid:   [3, 5],
    .MidTopRight: [5, 5],
    .MidMidRight: [5, 3],
    .MidBotRight: [5, 1],
    .MidBotMid:   [3, 1],
    .MidBotLeft:  [1, 1],
    .MidMidLeft:  [1, 3],
    .InnTopLeft:  [2, 4],
    .InnTopMid:   [3, 4],
    .InnTopRight: [4, 4],
    .InnMidRight: [4, 3],
    .InnBotRight: [4, 2],
    .InnBotMid:   [3, 2],
    .InnBotLeft:  [2, 2],
    .InnMidLeft:  [2, 3],
]
@IBDesignable
class NineMensMorrisView: NSView {
    @IBInspectable var circleRad: CGFloat = 10.0 {
        didSet {
            self.computeCentres()
            self.needsDisplay = true
        }
    }
    @IBInspectable var stoneRad: CGFloat = 25.0
    @IBInspectable var baseLen: CGFloat = 80.0 {
        didSet {
            centrePoint = self.computeCentres()
            self.needsDisplay = true
        }
    }
    @IBInspectable var lineWidth: CGFloat = 5.0
    var xOff: CGFloat = 130.0 {
        didSet {
            self.computeCentres()
        }
    }
    var yOff: CGFloat = 80.0 {
        didSet {
            self.computeCentres()
        }
    }
    lazy var centrePoint: [CGPoint] = self.computeCentres()
    var fieldClicked: ((Field) -> Void)?
    var board: [Color] = Array(repeating: .Blank, count: 24) {
        didSet {
            self.needsDisplay = true
        }
    }
    var takenStones: [Color: Int] = [.White: 0, .Black: 0] {
        didSet {
            self.needsDisplay = true
        }
    }
    var highLighted = Set<Int>() {
        didSet {
            self.needsDisplay = true
        }
    }
    var highLightedBlue = Set<Int>() {
        didSet {
            self.needsDisplay = true
        }
    }
    func computeCentres() -> [CGPoint] {
        centrePoint = Array(repeating: CGPoint(x: 0, y: 0), count: 24)
        for scale in [3, 2, 1] {
            for i in 0...2 {
                centrePoint[(3 - scale) * 8 + i] =
                    CGPoint(x: xOff + baseLen * CGFloat(scale * i + 3 - scale),
                            y: yOff + baseLen * CGFloat(3 + scale))
                centrePoint[(3 - scale) * 8 + 6 - i] =
                    CGPoint(x: xOff + baseLen * CGFloat(scale * i + 3 - scale),
                            y: yOff + baseLen * CGFloat(3 - scale))
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
        return centrePoint
    }
    func addCircle(_ i : Int, _ p: inout NSBezierPath) {
        p.appendOval(in: NSRect(x: centrePoint[i].x - circleRad,
                                y: centrePoint[i].y - circleRad,
                                width: 2 * circleRad, height: 2 * circleRad))
    }
    func addLineSegment(_ i: Int, _ j: Int, _ p: inout NSBezierPath,
                        _ deltaX: Int = 0, _ deltaY: Int = 0) {
        p.move(to: NSPoint(x: centrePoint[i].x + CGFloat(deltaX) * circleRad,
                           y: centrePoint[i].y + CGFloat(deltaY) * circleRad))
        p.line(to: NSPoint(x: centrePoint[j].x - CGFloat(deltaX) * circleRad,
                           y: centrePoint[j].y - CGFloat(deltaY) * circleRad))
    }
    func drawSquare2() {
        NSColor.black.setStroke()
        for i in 0...2 {
            var p = NSBezierPath()
            p.lineWidth = lineWidth
            addCircle(8 * i + 0, &p)
            addLineSegment(8 * i + 0, 8 * i + 1, &p, 1, 0)
            addCircle(8 * i + 1, &p)
            addLineSegment(8 * i + 1, 8 * i + 2, &p, 1, 0)
            addCircle(8 * i + 2, &p)
            addLineSegment(8 * i + 2, 8 * i + 3, &p, 0, -1)
            addCircle(8 * i + 3, &p)
            addLineSegment(8 * i + 3, 8 * i + 4, &p, 0, -1)
            addCircle(8 * i + 4, &p)
            addLineSegment(8 * i + 4, 8 * i + 5, &p, -1, 0)
            addCircle(8 * i + 5, &p)
            addLineSegment(8 * i + 5, 8 * i + 6, &p, -1, 0)
            addCircle(8 * i + 6, &p)
            addLineSegment(8 * i + 6, 8 * i + 7, &p, 0, 1)
            addCircle(8 * i + 7, &p)
            addLineSegment(8 * i + 7, 8 * i + 0, &p, 0, 1)
            p.stroke()
        }
    }
    func drawSquare(scale: Int) {
        NSColor.black.setStroke()
        let baseLen = self.baseLen * CGFloat(scale)
        let xOff = self.xOff + self.baseLen * CGFloat(3 - scale)
        let yOff = self.yOff + self.baseLen * CGFloat(3 - scale)
        let path = NSBezierPath(ovalIn: NSRect(x: xOff - circleRad, y: yOff, width: 2 * circleRad, height: 2 * circleRad))
        path.lineWidth = lineWidth
        path.move(to: NSPoint(x: xOff, y: yOff + 2 * circleRad))
        path.line(to: NSPoint(x: xOff, y: yOff + 2 * circleRad + 1 * baseLen))
        path.appendOval(in: NSRect(x: xOff - circleRad,y: yOff + 2 * circleRad + 1 * baseLen ,width: 2 * circleRad,height: 2 * circleRad))
        path.move(to: NSPoint(x: xOff, y: yOff + 4 * circleRad + 1 * baseLen))
        path.line(to: NSPoint(x: xOff, y: yOff + 4 * circleRad + 2 * baseLen))
        path.appendOval(in: NSRect(x: xOff - circleRad,y: yOff + 4 * circleRad + 2 * baseLen ,width: 2 * circleRad,height: 2 * circleRad))
        path.move(to: NSPoint(x: xOff + circleRad, y: yOff + 5 * circleRad  + 2 * baseLen))
        path.line(to: NSPoint(x: xOff + circleRad + baseLen, y: yOff + 5 * circleRad + 2 * baseLen))
        path.appendOval(in: NSRect(x:  xOff + circleRad + baseLen, y: yOff + 4 * circleRad + 2 * baseLen, width: 2 * circleRad, height: 2 * circleRad))
        path.move(to: NSPoint(x: xOff + 3 * circleRad + baseLen, y: yOff + 5 * circleRad  + 2 * baseLen))
        path.line(to: NSPoint(x: xOff + 3 * circleRad + 2 * baseLen, y: yOff + 5 * circleRad + 2 * baseLen))
        path.appendOval(in: NSRect(x:  xOff + 3 * circleRad + 2 * baseLen, y: yOff + 4 * circleRad + 2 * baseLen, width: 2 * circleRad, height: 2 * circleRad))
        path.move(to: NSPoint(x: xOff + 4 * circleRad + 2 * baseLen, y: yOff + 4 * circleRad  + 2 * baseLen))
        path.line(to: NSPoint(x: xOff + 4 * circleRad + 2 * baseLen, y: yOff + 4 * circleRad + 1 * baseLen))
        path.appendOval(in: NSRect(x:  xOff + 3 * circleRad + 2 * baseLen, y: yOff + 2 * circleRad + 1 * baseLen, width: 2 * circleRad, height: 2 * circleRad))
        path.move(to: NSPoint(x: xOff + 4 * circleRad + 2 * baseLen, y: yOff + 2 * circleRad  + 1 * baseLen))
        path.line(to: NSPoint(x: xOff + 4 * circleRad + 2 * baseLen, y: yOff + 2 * circleRad + 0 * baseLen))
        path.appendOval(in: NSRect(x:  xOff + 3 * circleRad + 2 * baseLen, y: yOff + 0 * circleRad + 0 * baseLen, width: 2 * circleRad, height: 2 * circleRad))
        path.move(to: NSPoint(x: xOff + 3 * circleRad + 2 * baseLen, y: yOff + 1 * circleRad  + 0 * baseLen))
        path.line(to: NSPoint(x: xOff + 3 * circleRad + 1 * baseLen, y: yOff + 1 * circleRad + 0 * baseLen))
        path.appendOval(in: NSRect(x:  xOff + 1 * circleRad + 1 * baseLen, y: yOff + 0 * circleRad + 0 * baseLen, width: 2 * circleRad, height: 2 * circleRad))
        path.move(to: NSPoint(x: xOff + 1 * circleRad + 1 * baseLen, y: yOff + 1 * circleRad  + 0 * baseLen))
        path.line(to: NSPoint(x: xOff + 1 * circleRad + 0 * baseLen, y: yOff + 1 * circleRad + 0 * baseLen))
        path.stroke()
    }
    func drawCross() {
        NSColor.black.setStroke()
        let horizontal = NSBezierPath()
        horizontal.lineWidth = lineWidth
        let yCoord = yOff + 3 * circleRad + 3 * baseLen
        horizontal.move(to: NSPoint(x: xOff + circleRad, y: yCoord))
        horizontal.relativeLine(to: NSPoint(x: baseLen - 2 * circleRad, y: 0))
        horizontal.relativeMove(to: NSPoint(x: 2 * circleRad, y: 0))
        horizontal.relativeLine(to: NSPoint(x: baseLen - 2 * circleRad, y: 0))
        horizontal.relativeMove(to: NSPoint(x: 2 * baseLen + 6 * circleRad, y: 0))
        horizontal.relativeLine(to: NSPoint(x: baseLen - 2 * circleRad, y: 0))
        horizontal.relativeMove(to: NSPoint(x: 2 * circleRad, y: 0))
        horizontal.relativeLine(to: NSPoint(x: baseLen - 2 * circleRad, y: 0))
        horizontal.stroke()
        let vertical = NSBezierPath()
        vertical.lineWidth = lineWidth
        vertical.move(to: NSPoint(x: xOff + 2 * circleRad + 3 * baseLen, y: yOff + 2 * circleRad))
        vertical.relativeLine(to: NSPoint(x: 0, y: baseLen - 2 * circleRad))
        vertical.relativeMove(to: NSPoint(x: 0, y: 2 * circleRad))
        vertical.relativeLine(to: NSPoint(x: 0, y: baseLen - 2 * circleRad))
        vertical.relativeMove(to: NSPoint(x: 0, y: 6 * circleRad + 2 * baseLen))
        vertical.relativeLine(to: NSPoint(x: 0, y: baseLen  - 2 * circleRad))
        vertical.relativeMove(to: NSPoint(x: 0, y: 2 * circleRad))
        vertical.relativeLine(to: NSPoint(x: 0, y: baseLen - 2 * circleRad))
        vertical.stroke()
    }
    func drawCross2() {
        NSColor.black.setStroke()
        var p = NSBezierPath()
        p.lineWidth = lineWidth
        addLineSegment(1,  9, &p, 0, -1)
        addLineSegment(9, 17, &p, 0, -1)
        addLineSegment(5, 13, &p, 0, 1)
        addLineSegment(13, 21, &p, 0, 1)
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
            NSColor.white.setFill()
            NSColor.white.setStroke()
        } else {
            NSColor.black.setFill()
            NSColor.black.setStroke()
        }
        let x = centrePoint[stone].x - stoneRad
        let y = centrePoint[stone].y - stoneRad
        let p = NSBezierPath(ovalIn: NSRect(x: x, y: y,
                                            width: 2 * stoneRad, height: 2 * stoneRad))
      
        p.fill()
        p.lineWidth = lineWidth
        if highLighted.contains(stone) {
            NSColor.red.setStroke()
        }
        if highLightedBlue.contains(stone) {
            NSColor.blue.setStroke()
        }
        p.stroke()
    }
    func drawStone(_ x: CGFloat, _ y: CGFloat, _ color: Color) {
        if (color == .Black) {
            NSColor.black.setFill()
        } else {
            NSColor.white.setFill()
        }
        let p = NSBezierPath(ovalIn: NSRect(x: x, y: y,
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
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.yellow.setFill()
        NSBezierPath(rect: dirtyRect).fill()
        xOff = (bounds.width - 6 * self.baseLen) / 2.0
        yOff = (bounds.height - 6 * self.baseLen) / 2.0
        drawSquare2()
        drawCross2()
        drawStones()
    }
 
  // Handled by controller
    override func mouseDown(with event: NSEvent) {
        let event_location = event.locationInWindow;
        let p = convert(event_location, from: nil)
        //NSLog("Click!%f %f", p.x, p.y)
        for (i, point) in centrePoint.enumerated() {
            if abs(p.x - point.x) < stoneRad && abs(p.y - point.y) < stoneRad {
                fieldClicked!(Field(rawValue: i)!)
                break
            }
        }
    }
}
