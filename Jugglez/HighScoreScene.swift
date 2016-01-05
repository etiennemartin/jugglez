//
//  HighScoreScene.swift
//  Jugglez
//
//  Created by Etienne Martin on 2015-01-24.
//  Copyright (c) 2015 Etienne Martin. All rights reserved.
//

import Foundation
import SpriteKit

class HighScoreScene: SKScene {
    
    // Last position used to place the high score
    private var _prevScorePos: CGPoint = CGPointZero
    private var _buttonTapSoundAction = SKAction.playSoundFileNamed("BallTap.wav", waitForCompletion: false)

    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = SKColor.themeDarkBackgroundColor()
        
        // Title Bg
        let bgHeight = self.size.height * 0.25
        let titleBg = SKShapeNode(rect: CGRectMake(0, self.size.height - bgHeight, self.size.width, bgHeight))
        titleBg.fillColor = SKColor.themeLightBackgroundColor()
        addChild(titleBg)
        
        // Title Label
        let message = "High Scores"
        let titleLabel = createLabelWithMessage(message)
        titleLabel.fontSize = 60
        titleLabel.position = CGPoint(x: size.width/2, y: size.height * 0.75 + 20)
        titleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        addChild(titleLabel)
        
        _prevScorePos = CGPoint(x: 75, y: titleLabel.position.y - 75)
        
        addScore("Easy:",   mode: GameMode.Easy,   score: String(GameScores.sharedInstance.easyHighScore))
        addScore("Medium:", mode: GameMode.Medium, score: String(GameScores.sharedInstance.mediumHighScore))
        addScore("Hard:",   mode: GameMode.Hard,   score: String(GameScores.sharedInstance.hardHighScore))
        addScore("Expert:", mode: GameMode.Expert, score: String(GameScores.sharedInstance.expertHighScore))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Clean high score flags
        GameScores.sharedInstance.clearHighScoreFlags()
        
        self.runAction(_buttonTapSoundAction)
        
        // Return to the main screen.
        let reveal = SKTransition.fadeWithColor(backgroundColor, duration: 0.50)
        let scene = IntroScene(size: size)
        self.view?.presentScene(scene, transition:reveal)
    }
    
    // Create a label and score node and properly positions them one below each other
    private func addScore(dificulty: String, mode: GameMode, score: String) {
        
        // Label
        let scoreLabel = createLabelWithMessage(dificulty)
        scoreLabel.position = _prevScorePos
        scoreLabel.fontColor = SKColor.colorForGameMode(mode)
        addChild(scoreLabel)
        
        // Score
        let scoreValue = createRightAlignedLabel(score)
        scoreValue.position = CGPoint(x: size.width - 75, y:_prevScorePos.y)
        scoreValue.fontColor = SKColor.colorForGameMode(mode)
        addChild(scoreValue)
        
        let scoreBg = SKShapeNode(rectOfSize: CGSizeMake(size.width, 50))
        scoreBg.fillColor = SKColor.themeLightBackgroundColor()
        scoreBg.position = CGPointMake(size.width / 2, _prevScorePos.y + 12)
        addChild(scoreBg)
        
        if (GameScores.sharedInstance.isRecordNewForMode(mode)) {
            // New high score
            let newBg = SKShapeNode(rect: CGRectMake(0,0,34,24), cornerRadius: 3)
            newBg.fillColor = SKColor.colorForGameMode(mode)
            newBg.strokeColor = SKColor.colorForGameMode(mode)
            newBg.position = CGPointMake(scoreValue.position.x + 10, scoreValue.position.y)
            addChild(newBg)
            let newLabel = SKLabelNode(fontNamed: SKLabelNode.defaultFontName())
            newLabel.fontColor = SKColor.themeLightBackgroundColor()
            newLabel.text = "NEW!"
            newLabel.fontSize = 16
            newLabel.position = CGPointMake((newBg.frame.size.width / 2) - 1, 5)
            newBg.addChild(newLabel)

            // Jump back and forth (Like a happy kid)
            let jumpHeight: CGFloat = 8.0
            let jumpWidth: CGFloat = 8.0
            let jumpTime = 0.40
            
            // Vertical Jump action
            let jumpUp: SKAction = SKAction.moveByX(0, y: jumpHeight, duration: jumpTime/2)
            jumpUp.timingMode = SKActionTimingMode.EaseOut
            let jumpDown = SKAction.moveByX(0, y: -jumpHeight, duration: jumpTime/2)
            jumpDown.timingMode = SKActionTimingMode.EaseOut
            let jumpVert = SKAction.sequence([jumpUp, jumpDown])
            
            // Horizontal back and forth action
            let jumpRight: SKAction = SKAction.moveByX(jumpWidth, y: 0, duration: jumpTime)
            let jumpLeft: SKAction = SKAction.moveByX(-jumpWidth, y: 0, duration: jumpTime)
            
            let jumpAction = SKAction.sequence([
                SKAction.group([jumpVert, jumpRight]),
                SKAction.group([jumpVert, jumpLeft])])
            newBg.runAction(SKAction.repeatActionForever(jumpAction))
            
        }
        
        // Update position for the next
        _prevScorePos = scoreLabel.position
        _prevScorePos.y -= 65
    }
    
    // Creates a left aligned label
    private func createLabelWithMessage(message: String) -> SKLabelNode {
        let label = SKLabelNode()
        label.fontColor = SKColor.themeDarkFontColor()
        label.fontName = SKLabelNode.defaultFontName()
        label.text = message
        label.fontSize = 30
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        return label
    }
    
    // Creates a right aligned label
    private func createRightAlignedLabel(message: String) -> SKLabelNode {
        let label = createLabelWithMessage(message)
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        return label
    }
    
}