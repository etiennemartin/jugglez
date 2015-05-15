//
//  GameScene.swift
//  JuggleGame
//
//  Created by Etienne Martin on 2015-01-17.
//  Copyright (c) 2015 Etienne Martin. All rights reserved.
//

import SpriteKit

// Point of reference for the gravity. Gravity for all modes are based off this value.
// Game Modes:
// - Easy:   33% gravity
// - Medium: 75% gravity
// - Hard:   100% gravity
// - Expert: 33% gravity, can't drop a ball
private let k_baseGravity : CGFloat = -9.8
private let k_easyModeGravityFactor   : CGFloat = 0.33
private let k_mediumModeGravityFactor : CGFloat = 0.75
private let k_hardModeGravityFactor   : CGFloat = 1.00
private let k_expertModeGravityFactor : CGFloat = 0.33

// Determines how much the gravity will increase with each ball dropped.
private let k_gravityIncreaseFactor : CGFloat = 1.0

// Scene count down variables
private let k_countDownNumberInterval : NSTimeInterval = 0.65
private let k_countDownFontSize : CGFloat = 60

// Maximum number of touches allowed at once. This limit prevents users from rapidly
// tapping the screen with a "wall" of fingers. If done quick enough the user could prevent
// any of the balls from falling.
private let k_maxNumberConcurrentTouches : Int  = 2

struct PhysicaCollisionMask {
    static let None   : UInt32 = 0
    static let All    : UInt32 = UInt32.max
    static let Ball   : UInt32 = 0b1
    static let Bounds : UInt32 = 0b10
}

class GamePlayScene: SKScene, SKPhysicsContactDelegate {
    
    init (size: CGSize, mode:GameMode) {
        super.init(size: size)
        setGameMode(mode)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor.themeLightBackgroundColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        physicsWorld.gravity = gravityForMode(mode)
        physicsWorld.contactDelegate = self
        
        // Create background and start it's animation
        _background = GravityBackground(size: self.size)
        addChild(_background!)
        
        createBoundingBox()
        startCountdown(3)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        var numTouches : Int = 1
        for uitouch in touches {

            if (numTouches > k_maxNumberConcurrentTouches) {
                break;
            }
            
            var touch = uitouch as! UITouch // downcast
            var location = touch.locationInNode(self)
            
            // Determine if it contacts with a ball
            for node in children {
                
                if (node is Ball) {
                 
                    let ball = node as! Ball

                    if (distanceBetweenPoints(ball.position, location) < 60) {
                        
                        // Determine where we touched the ball, and make it fly in the opposite directions
                        var deltaX = ball.position.x - location.x
                        ball.physicsBody?.velocity = CGVector(dx: deltaX * 75, dy: 1000)
                        _taps++
                        _totalTaps++

                        // Sound
                        self.runAction(_ballTapSoundAction)

                        // Level up!
                        if (_taps == 5) {
                            _taps = 0
                            addBall()
                        }
                        
                        break // Only one ball per tap
                    }
                }
            }
            
            addTapCircle(location)
            numTouches++
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        // Order the first body and second body
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Ball hits wall
        if (firstBody.categoryBitMask & PhysicaCollisionMask.Ball != 0 &&
            secondBody.categoryBitMask & PhysicaCollisionMask.Bounds != 0)
        {
            self.runAction(_ballHitWallSoundAction)
            
            var ball = firstBody.node as! Ball
            ball.collide(nil)
            if (ball.position.y < _ballRadius * 2) {
                explodeBall(ball)
            }
        }
        
        // Ball hits Ball
        if (firstBody.categoryBitMask & PhysicaCollisionMask.Ball != 0 &&
            secondBody.categoryBitMask & PhysicaCollisionMask.Ball != 0)
        {
            self.runAction(_ballHitBallSoundAction)
            
            var ball1 = firstBody.node as! Ball
            var ball2 = secondBody.node as! Ball
            
            ball1.collide(ball2)
            ball2.collide(ball1)
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        super.update(currentTime)

        var delta = currentTime - _prevUpdateTime
        _updateDelta += delta
        _prevUpdateTime = currentTime

        if (_updateDelta > 1.0) {
            processOutOfBounds()
            _updateDelta = 0
        }
    }
    
    private func createBoundingBox() {
        
        // Create Bounding box
        let boundingBox = SKShapeNode(rect: self.frame)
        boundingBox.strokeColor = foregroundColor
        boundingBox.fillColor = SKColor.clearColor()
        boundingBox.lineWidth = 5
        boundingBox.physicsBody = SKPhysicsBody(edgeLoopFromRect: boundingBox.frame)
        boundingBox.physicsBody?.categoryBitMask = PhysicaCollisionMask.Bounds
        boundingBox.physicsBody?.contactTestBitMask = PhysicaCollisionMask.Ball
        addChild(boundingBox)
        
        // Create explosion box
        let expBox = SKShapeNode(rect: CGRectMake(0, 0, size.width, 15))
        expBox.fillColor = foregroundColor.colorWithAlphaComponent(0.5)
        expBox.lineWidth = 0
        addChild(expBox)
        
        let fadeDuration = 0.75
        let fadeOut = SKAction.fadeAlphaTo(0.0, duration: fadeDuration)
        fadeOut.timingMode = SKActionTimingMode.EaseIn
        let fadeIn = SKAction.fadeAlphaTo(1.0, duration: fadeDuration)
        fadeIn.timingMode = SKActionTimingMode.EaseIn
        expBox.runAction(SKAction.repeatActionForever(SKAction.sequence([fadeOut, fadeIn])))
    }
    
    // Adds a small expanding circle where the user has tapped.
    private func addTapCircle(location: CGPoint) {
        
        let tapCircle = SKShapeNode(circleOfRadius: 20)
        tapCircle.fillColor = SKColor.clearColor()
        tapCircle.strokeColor = foregroundColor
        tapCircle.position = location
        addChild(tapCircle)
        
        // Sound
        tapCircle.runAction(_tapSoundAction)
        
        // Animate
        let animationTime = 0.3
        let fadeOutAction = SKAction.fadeAlphaTo(0.0, duration: animationTime)
        let scaleAction = SKAction.scaleBy(2.0, duration: animationTime)
        scaleAction.timingMode = SKActionTimingMode.EaseOut
        tapCircle.runAction(fadeOutAction)
        tapCircle.runAction(SKAction.sequence([
            scaleAction,
            SKAction.runBlock() {
                tapCircle.removeFromParent()
            }]))
    }
    
    // This function is required since the physics of the scene may miss a collision if the
    // frame rate is low. If this happens we destroy the ball and recreate it within the scene
    private func processOutOfBounds() {
        var i = 0
        var removed = 0
        
        // Remove balls that are out of bounds
        while i < _balls.endIndex {
            var ball : Ball = _balls[i]
            if (ball.position.x < -_ballRadius || ball.position.x > self.size.width + _ballRadius ||
                ball.position.y < -_ballRadius || ball.position.y > self.size.height + _ballRadius)
            {
                println("Removing ball that is out of bounds")
                _balls.removeAtIndex(i)
                removed++
            }
            i++
        }
        
        // Replace ball with a ball in bounds
        if (removed > 0) {
            for x in 1...removed {
                addBall()
            }
        }
    }
    
    // Sets the Gravity based on the game mdoe
    private func gravityForMode(mode:GameMode) -> CGVector {

        let baseGravity = k_baseGravity
        
        if (mode == GameMode.Easy) {
            return CGVectorMake(0.0, CGFloat(baseGravity * k_easyModeGravityFactor))
        }
        else if (mode == GameMode.Medium) {
            return CGVectorMake(0.0, CGFloat(baseGravity * k_mediumModeGravityFactor))
        }
        else if (mode == GameMode.Hard) {
            return CGVectorMake(0.0, CGFloat(baseGravity * k_hardModeGravityFactor))
        }
        else if (mode == GameMode.Expert) {
            return CGVectorMake(0.0, CGFloat(baseGravity * k_expertModeGravityFactor))
        }
        
        return CGVectorMake(0.0, 0.0)
    }
    
    // Starts off the countdown animation
    private func startCountdown(number: Int) {
        
        if (number == 0) {
            for i in 1..._startingNumberOfBalls {
                addBall()
            }
            return
        }
        
        self.runAction(self._ballHitWallSoundAction)
        
        let label = SKLabelNode()
        label.text = NSString(format: "%d", number) as String
        label.fontName = SKLabelNode.defaultFontName()
        label.fontSize = k_countDownFontSize
        label.fontColor = foregroundColor
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        var countInterval = k_countDownNumberInterval
        var scaleBall = SKAction.scaleTo(4.0, duration: countInterval)
        var fadeBall = SKAction.fadeOutWithDuration(countInterval)
        var explodeBall = SKAction.group([fadeBall, scaleBall])
        var removeBall = SKAction.removeFromParent()
        var nextLabel = SKAction.runBlock { () -> Void in
            self.startCountdown(number - 1)
        }
        label.runAction(SKAction.sequence([explodeBall, nextLabel, removeBall]))
    }
    
    // Adds a ball at the top of the screen at a random location
    private func addBall() {
        
        // Position at random location
        var position = CGPoint(
            x: self.size.width - random(min:0, self.size.width),
            y: self.size.height - _ballRadius*2)
        
        // Create Ball
        var ball = Ball(radius: _ballRadius, color: foregroundColor, position: position)
        ball.alpha = 0.0
        
        // Fade the ball in
        ball.runAction(SKAction.fadeAlphaTo(1.0, duration: 0.2))
        
        addChild(ball)
        _balls.append(ball)
    }
    
    // Final animation when the ball hits the floor
    private func explodeBall(ball: Ball) {
        
        self.runAction(_explosionSoundAction)
        ball.physicsBody?.collisionBitMask = PhysicaCollisionMask.None
        ball.physicsBody?.categoryBitMask = PhysicaCollisionMask.None
        ball.physicsBody?.affectedByGravity = false
        
        for i in 0..._balls.count {
            if (_balls[i] == ball) {
                _balls.removeAtIndex(i)
                _background?.increaseDropSpeed()
                break
            }
        }
        
        println(NSString(format: "Balls remaining: %d", _balls.count))
        
        // Setup explosion animation
        var scaleBall = SKAction.scaleTo(4.0, duration: 0.25)
        var fadeBall = SKAction.fadeOutWithDuration(0.25)
        var explodeBall = SKAction.group([fadeBall, scaleBall])
        var explodeBalldone = SKAction.removeFromParent()
        var loseAction = SKAction.runBlock { () -> Void in
            
            // Determine if the game is over
            if (self._balls.count == 0 || self.mode == GameMode.Expert)
            {
                println("Game over dude!")
                let reveal = SKTransition.fadeWithColor(self.backgroundColor, duration: 0.75)
                let scene = GameOverScene(size: self.size, finalScore:self._totalTaps, gameMode:self.mode)
                scene.backgroundColor = self.backgroundColor
                scene.foregroundColor = self.foregroundColor
                self.view?.presentScene(scene, transition:reveal)
            }
            
        }
        ball.runAction(SKAction.sequence([explodeBall, loseAction, explodeBalldone]))
        
        // Amp up the gravity
        physicsWorld.gravity.dy -= k_gravityIncreaseFactor
    }
    
    // Sets up all the game play variables based on the mode. All expect for the Gravity.
    private func setGameMode(mode : GameMode)
    {
        _gameMode = mode
        
        if (mode == GameMode.Easy)
        {
            _ballRadius = 20
        }
        else if (mode == GameMode.Medium)
        {
            _ballRadius = 15
        }
        else if (mode == GameMode.Hard)
        {
            _ballRadius = 10
        }
        else if (mode == GameMode.Expert)
        {
            _ballRadius = 12
        }
        
        foregroundColor = SKColor.whiteColor()
        backgroundColor = SKColor.colorForGameMode(mode)
    }
    
    internal var mode : GameMode {
        get {
            return _gameMode
        }
        set(value) {
            self.setGameMode(value)
        }
    }
    
    internal var foregroundColor : SKColor = SKColor.blackColor()
    
    private var _gameMode : GameMode = GameMode.None
    private var _balls : Array<Ball> = Array<Ball>()
    private var _ballRadius = CGFloat(15)
    private let _startingNumberOfBalls = 1
    private var _taps : Int = 0
    private var _totalTaps : Int64 = 0
    
    private var _prevUpdateTime : CFTimeInterval = 0
    private var _updateDelta : CFTimeInterval = 0
    
    private var _background : GravityBackground? = nil
    
    // Sounds
    private var _explosionSoundAction   = SKAction.playSoundFileNamed("Explosion1.wav", waitForCompletion: false)
    private var _ballHitBallSoundAction = SKAction.playSoundFileNamed("Ball2BallHit.wav", waitForCompletion: false)
    private var _ballHitWallSoundAction = SKAction.playSoundFileNamed("Ball2WallHit.wav", waitForCompletion: false)
    private var _ballTapSoundAction     = SKAction.playSoundFileNamed("BallTap.wav", waitForCompletion: false)
    private var _tapSoundAction         = SKAction.playSoundFileNamed("Tap.wav", waitForCompletion: false)
}
