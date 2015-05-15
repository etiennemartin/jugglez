//
//  MathOps.swift
//  DemoGame
//
//  Created by Etienne Martin on 2015-01-17.
//  Copyright (c) 2015 Etienne Martin. All rights reserved.
//

import SpriteKit

public var PI : Double = 3.14159265359

// CGPoint overloads
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

// CGPoint extension
extension CGPoint {
    
    func length() -> CGFloat {
        return sqrt(x * x + y * y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

// Random float value
func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

// Random value between min and max
func random(#min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}

// Distance between two CGPoints
func distanceBetweenPoints(p1: CGPoint, p2: CGPoint) -> CGFloat {
    var xDst = p2.x - p1.x
    var yDst = p2.y - p1.y
    return sqrt((xDst * xDst) + (yDst * yDst))
}

func degreesToRadians(degrees : Double) -> Double {
    return degrees * (PI/180.0)
}

func radiansToDegrees(radians : Double) -> Double {
    return radians * (180.0/PI)
}

