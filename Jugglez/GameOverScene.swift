//
//  GameOverScene.swift
//  Jugglez
//
//  Created by Etienne Martin on 2015-01-18.
//  Copyright (c) 2015 Etienne Martin. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, finalScore:Int64, gameMode:GameMode) {
        score = finalScore
        mode = gameMode
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        let message = "Game Over!"
        
        // Main Message
        let label = SKLabelNode()
        label.text = message
        label.fontName = SKLabelNode.defaultFontName()
        label.fontSize = 60
        label.fontColor = foregroundColor
        label.position = CGPoint(x: size.width/2, y: (size.height/2) + label.fontSize)
        addChild(label)
        
        let oldScore = GameScores.sharedInstance.getScoreForMode(mode)
        
        // Score
        let scoreLabel = SKLabelNode()
        
        if (oldScore < score) {
            scoreLabel.text = NSString(format: "New High Score! %d", score) as String
        } else {
            scoreLabel.text = NSString(format: "Score: %d", score) as String
        }
        
        scoreLabel.fontName = SKLabelNode.defaultFontName()
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = foregroundColor
        scoreLabel.position = label.position
        scoreLabel.position.y -= 60
        addChild(scoreLabel)
        
        let buttonWidth = self.size.width / 6
        let buttonYOffset = self.size.height / 3
        let buttonSize = CGSizeMake(34, 34)
        
        // Retry Button
        _homeButton = SKSpriteNode(imageNamed: "home")
        _homeButton?.position = CGPointMake(buttonWidth * 1.5, buttonYOffset)
        _homeButton?.size = buttonSize
        addChild(_homeButton!)
        
        // Main Menu Button
        _retryButton = SKSpriteNode(imageNamed: "retry")
        _retryButton?.position = CGPointMake(buttonWidth * 3, buttonYOffset)
        _retryButton?.size = buttonSize
        addChild(_retryButton!)
        
        // High scores
        _highScoreButton = SKSpriteNode(imageNamed: "highscore")
        _highScoreButton?.position = CGPointMake(buttonWidth * 4.5, buttonYOffset)
        _highScoreButton?.size = buttonSize
        addChild(_highScoreButton!)
        
        // Save score
        GameScores.sharedInstance.setScoreForMode(mode, score: score)
        GameScores.sharedInstance.save()
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first!
        let location = touch.locationInNode(self)
        var scene : SKScene? = nil
        
        let homeButtonRect = _homeButton!.frame
        if (CGRectContainsPoint(homeButtonRect, location)) {
            scene = IntroScene(size: self.size)
        }
        
        let retryButtonRect = _retryButton!.frame
        if (CGRectContainsPoint(retryButtonRect, location)) {
            scene = GamePlayScene(size: self.size, mode:mode)
        }
        
        let highScoreButtonRect = _highScoreButton!.frame
        if (CGRectContainsPoint(highScoreButtonRect, location)) {
            scene = HighScoreScene(size: self.size)
        }
        
        if (scene != nil) {
            self.runAction(_buttonTapSoundAction)
            runAction(SKAction.runBlock() {
                let reveal = SKTransition.fadeWithColor(self.backgroundColor, duration: 0.75)
                self.view?.presentScene(scene!, transition:reveal)
            })
        }
    }

    internal var mode : GameMode
    internal var score : Int64
    internal var foregroundColor : SKColor = SKColor.themeLightBackgroundColor()

    private var _homeButton : SKSpriteNode?
    private var _retryButton : SKSpriteNode?
    private var _highScoreButton : SKSpriteNode?
    
    private var _buttonTapSoundAction = SKAction.playSoundFileNamed("BallTap.wav", waitForCompletion: false)
}
