//
//  Ball.swift
//  Jugglez
//
//  Created by Etienne Martin on 2015-02-08.
//  Copyright (c) 2015 Etienne Martin. All rights reserved.
//

import SpriteKit

class Ball : SKShapeNode {

    init(radius:CGFloat, color:SKColor, position:CGPoint) {
        _ballColor = color
        _faceNode = nil
        super.init()
        self.position = position
 
        //Physics
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.dynamic = true
        physicsBody?.affectedByGravity = true
        physicsBody?.usesPreciseCollisionDetection = true
        physicsBody?.categoryBitMask = PhysicaCollisionMask.Ball
        physicsBody?.contactTestBitMask = PhysicaCollisionMask.Bounds | PhysicaCollisionMask.Ball
        
        // Visuals
        var ball = SKShapeNode(circleOfRadius: radius)
        ball.strokeColor = SKColor.clearColor()
        ball.fillColor = color
        ball.name = "ball_node"
        addChild(ball)
        calculateAccumulatedFrame()
        
        _faceNode = SKSpriteNode(imageNamed: "faceSmile")
        _faceNode?.size = CGSizeMake(radius*2, radius*2)
        _faceNode?.name = "face_node"
        addChild(_faceNode!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collide(otherBall : Ball?)
    {
        // Show a different face
        runAction(SKAction.sequence([
            SKAction.runBlock() {
                self._faceNode!.texture = SKTexture(imageNamed: "faceHit")
            },
            SKAction.waitForDuration(0.2), // 200ms
            SKAction.runBlock() {
                self._faceNode!.texture = SKTexture(imageNamed: "faceSmile")
            }
            ]))
    }
    
    private var _ballColor : SKColor
    private var _faceNode : SKSpriteNode?
}