//
//  GameScene.swift
//  JuggleGame
//
//  Created by Etienne Martin on 2015-01-17.
//  Copyright (c) 2015 Etienne Martin. All rights reserved.
//

import SpriteKit

public enum GameMode : Printable {
    case None
    case Easy
    case Medium
    case Hard
    case Expert
    case HighScore
    
    public var description : String {
        switch self {
        case .None:   return "None"
        case .Easy:   return "Easy"
        case .Medium: return "Medium"
        case .Hard:   return "Hard"
        case .Expert: return "Expert"
        case .HighScore: return "High scores"
        }
    }
    
    // Static set of all modes. Useful for enumerating
    public static let allModes = [Easy, Medium, Hard, Expert]
}

struct GameModeButton {
    var mode : GameMode
    var node : Button
}

class IntroScene: SKScene {
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = SKColor.themeDarkBackgroundColor()
        
        // Title Bg
        var bgHeight = self.size.height * 0.25
        var titleBg = SKShapeNode(rect: CGRectMake(0, self.size.height - bgHeight, self.size.width, bgHeight))
        titleBg.fillColor = SKColor.themeLightBackgroundColor()
        addChild(titleBg)
        
        // Title Label
        var endPosition = CGPointMake(self.size.width / 2, self.size.height * 0.75 + 20)
        var startPosition = CGPointMake(self.size.width / 2, self.size.height + 75)
        var label = SKLabelNode(text: "Jugglez")
        label.fontName = SKLabelNode.defaultFontName()
        label.fontSize = 80
        label.fontColor = SKColor.themeDarkFontColor()
        label.position = startPosition
        addChild(label)
        
        // Animate title in
        var moveAction = SKAction.moveTo(endPosition, duration: 0.75)
        moveAction.timingMode = SKActionTimingMode.EaseOut
        label.runAction(moveAction)
        
        // Buttons
        var position = self.size.height * 0.75
        var gap = min( ((self.size.height * 0.75) / 5) - 10, 75)
        var xOffset = self.size.width / 6
        
        addButtonWithLabel(GameMode.Easy,      position: CGPointMake(xOffset, position - gap))
        addButtonWithLabel(GameMode.Medium,    position: CGPointMake(xOffset, position - (gap * 2)))
        addButtonWithLabel(GameMode.Hard,      position: CGPointMake(xOffset, position - (gap * 3)))
        addButtonWithLabel(GameMode.Expert,    position: CGPointMake(xOffset, position - (gap * 4)))
        addButtonWithLabel(GameMode.HighScore, position: CGPointMake(xOffset, position - (gap * 5)))
        
        // Version
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
        let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as! String
        var versionLabel = SKLabelNode(fontNamed: SKLabelNode.defaultFontName())
        versionLabel.text = String(format: "%@ (%@)", arguments: [version, build])
        versionLabel.fontColor = SKColor.themeDarkFontColor().colorWithAlphaComponent(0.8)
        versionLabel.fontSize = 16
        versionLabel.position = CGPointMake(versionLabel.frame.size.width / 2 + 5, 5)
        addChild(versionLabel)
        
        // Add Git hub icon
        self.addGitHubLink()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        var touch = touches.first as! UITouch
        var location = touch.locationInNode(self)
        
        // Detect touch with buttons
        for button in _buttons {
            
            let buttonRect : CGRect = button.node.calculateAccumulatedFrame()
            
            if (CGRectContainsPoint(buttonRect, location)) {
                
                let reveal = SKTransition.fadeWithColor(backgroundColor, duration: 0.75)

                button.node.foregroundColor = SKColor.colorForGameMode(button.mode).colorWithAlphaComponent(0.25)
                
                self.runAction(_buttonTapSoundAction)
                
                if (button.mode == GameMode.HighScore) {
                    // Present high score scene
                    let scene = HighScoreScene(size: self.size)
                    scene.scaleMode = .ResizeFill
                    self.view?.presentScene(scene, transition:reveal)
                } else {
                    // Present game scene
                    let scene = GamePlayScene(size: self.size)
                    scene.scaleMode = .ResizeFill
                    scene.mode = button.mode
                    self.view?.presentScene(scene, transition:reveal)
                }
                
                break;
            }
        }
        
        // Detect touch with gitHub icon
        var gitHubRect : CGRect = _gitHubNode!.calculateAccumulatedFrame()
        if (CGRectContainsPoint(gitHubRect, location)) {
            
            var url = NSURL(string: _gitHubRepoUrl)
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        super.update(currentTime)
    }
    
    func addButtonWithLabel(mode:GameMode, position:CGPoint) {
        
        var nodeButton : Button = Button(frame: CGRectMake(0, 0, self.size.width * 0.67, 50), text: mode.description)
        nodeButton.position = position
        nodeButton.position.y = -75
        nodeButton.foregroundColor = SKColor.colorForGameMode(mode)
        nodeButton.textColor = SKColor.themeButtonTextColor()

        addChild(nodeButton)
        
        // Animate button in
        var moveAction = SKAction.moveTo(position, duration: 0.75)
        moveAction.timingMode = SKActionTimingMode.EaseOut
        nodeButton.runAction(moveAction)
        
        var modeButton = GameModeButton(mode: mode, node: nodeButton)
        _buttons.append(modeButton)
    }
    
    func addGitHubLink() {
        
        var dim : CGFloat = 24.0
        _gitHubNode = SKSpriteNode(imageNamed: "GitHub-Mark-120px-plus")
        _gitHubNode?.size = CGSizeMake(dim, dim)
        var startPos = CGPointMake(self.size.width + dim, dim)
        var endPos = CGPointMake(self.size.width - dim, dim)
        _gitHubNode?.position = startPos
        _gitHubNode?.runAction(SKAction.moveTo(endPos, duration: 0.75))
        
        addChild(_gitHubNode!)
    }
    
    private var _buttonTapSoundAction = SKAction.playSoundFileNamed("BallTap.wav", waitForCompletion: false)
    private var _gitHubRepoUrl : String = "https://github.com/etiennemartin/jugglez"
    private var _gitHubNode : SKSpriteNode?
    private var _buttons : Array<GameModeButton> = Array<GameModeButton>()
}