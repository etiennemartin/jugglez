//
//  GravityBackground.swift
//  Jugglez
//
//  Created by Etienne Martin on 2015-04-20.
//  Copyright (c) 2015 Etienne Martin. All rights reserved.
//

import Foundation
import SpriteKit

// Size of the background sprites
private let k_backgroundSpriteSize : CGFloat = 20
// Number of sprites we want on the background
private let k_backgroundSpriteCount : Int = 30
// Base amount of time it takes for the background sprite to drop off screen
private let k_backgroundSpriteDropTime : NSTimeInterval = 10.0 // sec
// Alpha channel of the background node
private let k_backgroundSpriteAlpha : CGFloat = 0.15

// This coefficient is used to decrease the time it takes for a background sprite to drop
// off the screen. The time it takes for a sprite to fall off the screen is calculated as
// follows
// time = k_backgroundSpriteDropTime - (k_backgrountGravitycoefficient * number of dropped balls)
private let k_backgroundGravityCoefficient : NSTimeInterval = 0.5

class GravityBackground : SKNode {
    
    init (size: CGSize) {
        _dropSpeed = 0
        _size = size
        super.init()

        addBackgroundDroppingSprite()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func increaseDropSpeed() {
        _dropSpeed++
    }
    
    // Adds a single image to the background that falls. The speed should indicate how strong
    // the gravity in the back is.
    private func addBackgroundDroppingSprite() {
        
        let nodeHeight : CGFloat = k_backgroundSpriteSize
        let dropTime : NSTimeInterval = NSTimeInterval(
            max(0.25,
                k_backgroundSpriteDropTime - (k_backgroundGravityCoefficient * NSTimeInterval(_dropSpeed)))
        )
        
        let node = SKSpriteNode(imageNamed: "bgImage")
        node.size = CGSizeMake(nodeHeight, nodeHeight)
        node.alpha = k_backgroundSpriteAlpha
        addChild(node)
        
        let position = CGPoint(
            x: _size.width - random(0, max: _size.width),
            y: _size.height + nodeHeight)
        
        // Drop action
        node.position = position
        let rotationAngle : CGFloat = CGFloat(degreesToRadians(1080.0))
        let fallAction = SKAction.moveToY(-_size.height + (2*nodeHeight), duration: dropTime)
        fallAction.timingMode = SKActionTimingMode.EaseIn
        let rotationAction = SKAction.rotateByAngle(rotationAngle, duration: dropTime)
        let fallRotAction = SKAction.group([fallAction, rotationAction])
        
        // Queue next node action
        let waitAction = SKAction.waitForDuration(dropTime/Double(k_backgroundSpriteCount))
        let addNextAction = SKAction.runBlock { () -> Void in
            self.addBackgroundDroppingSprite()
        }
        let queueNextAction = SKAction.sequence([waitAction, addNextAction])
        
        let dropAction = SKAction.group([fallRotAction, queueNextAction])
        
        node.runAction(SKAction.sequence([
            dropAction,
            SKAction.runBlock({ () -> Void in
                node.removeFromParent()
            })
        ]))
    }
    
    private var _dropSpeed : Int
    private var _size : CGSize
}