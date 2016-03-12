//
//  GameScene.swift
//  JuggleGame
//
//  Created by Etienne Martin on 2015-01-17.
//  Copyright (c) 2015 Etienne Martin. All rights reserved.
//

import SpriteKit

public enum GameMode: CustomStringConvertible {
    case None
    case Easy
    case Medium
    case Hard
    case Expert
    case HighScore

    public var description: String {
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
    var mode: GameMode
    var node: Button
}

class IntroScene: SKScene {
    private var _buttonTapSoundAction = SKAction.playSoundFileNamed("BallTap.wav", waitForCompletion: false)
    private var _gitHubRepoUrl: String = "https://github.com/etiennemartin/jugglez"
    private var _gitHubNode: SKSpriteNode?
    private var _buttons: [GameModeButton] = []

    override init(size: CGSize) {
        super.init(size: size)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.themeDarkBackgroundColor()

        // Title Bg
        let bgHeight = self.size.height * 0.25
        let titleBg = SKShapeNode(rect: CGRect(x: 0, y: self.size.height - bgHeight, width: self.size.width, height: bgHeight))
        titleBg.fillColor = SKColor.themeLightBackgroundColor()
        addChild(titleBg)

        // Title Label
        let endPosition = CGPoint(x: self.size.width / 2, y: self.size.height * 0.75 + 20)
        let startPosition = CGPoint(x: self.size.width / 2, y: self.size.height + 75)
        let label = SKLabelNode(text: "Jugglez")
        label.fontName = SKLabelNode.defaultFontName()
        label.fontSize = 80
        label.fontColor = SKColor.themeDarkFontColor()
        label.position = startPosition
        addChild(label)

        // Animate title in
        let moveAction = SKAction.moveTo(endPosition, duration: 0.75)
        moveAction.timingMode = SKActionTimingMode.EaseOut
        label.runAction(moveAction)

        // Buttons
        let position = self.size.height * 0.75
        let gap = min( ((self.size.height * 0.75) / 5) - 10, 75)
        let xOffset = self.size.width / 6

        addButtonWithLabel(GameMode.Easy, position: CGPoint(x: xOffset, y: position - gap))
        addButtonWithLabel(GameMode.Medium, position: CGPoint(x: xOffset, y: position - (gap * 2)))
        addButtonWithLabel(GameMode.Hard, position: CGPoint(x: xOffset, y: position - (gap * 3)))
        addButtonWithLabel(GameMode.Expert, position: CGPoint(x: xOffset, y: position - (gap * 4)))
        addButtonWithLabel(GameMode.HighScore, position: CGPoint(x: xOffset, y: position - (gap * 5)))

        // Version
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"]
        let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"]
        let versionLabel = SKLabelNode(fontNamed: SKLabelNode.defaultFontName())
        versionLabel.text = "\(version!) (\(build!))"
        versionLabel.fontColor = SKColor.themeDarkFontColor().colorWithAlphaComponent(0.8)
        versionLabel.fontSize = 16
        versionLabel.position = CGPoint(x: versionLabel.frame.size.width / 2 + 5, y: 5)
        addChild(versionLabel)

        // Add Git hub icon
        self.addGitHubLink()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInNode(self)

        // Detect touch with buttons
        for button in _buttons {
            let buttonRect: CGRect = button.node.calculateAccumulatedFrame()

            if (CGRectContainsPoint(buttonRect, location)) {

                let reveal = SKTransition.fadeWithColor(backgroundColor, duration: 0.75)

                button.node.foregroundColor = SKColor.colorForGameMode(button.mode).colorWithAlphaComponent(0.25)

                self.runAction(_buttonTapSoundAction)

                if button.mode == GameMode.HighScore {
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
                break
            }
        }

        // Detect touch with gitHub icon
        let gitHubRect: CGRect = _gitHubNode!.calculateAccumulatedFrame()
        if (CGRectContainsPoint(gitHubRect, location)) {
            let url = NSURL(string: _gitHubRepoUrl)
            UIApplication.sharedApplication().openURL(url!)
        }
    }

    override func update(currentTime: CFTimeInterval) {
        super.update(currentTime)
    }

    func addButtonWithLabel(mode: GameMode, position: CGPoint) {

        let nodeButton: Button = Button(frame: CGRect(x: 0, y: 0, width: self.size.width * 0.67, height: 50), text: mode.description)
        nodeButton.position = position
        nodeButton.position.y = -75
        nodeButton.foregroundColor = SKColor.colorForGameMode(mode)
        nodeButton.textColor = SKColor.themeButtonTextColor()

        addChild(nodeButton)

        // Animate button in
        let moveAction = SKAction.moveTo(position, duration: 0.75)
        moveAction.timingMode = SKActionTimingMode.EaseOut
        nodeButton.runAction(moveAction)

        let modeButton = GameModeButton(mode: mode, node: nodeButton)
        _buttons.append(modeButton)
    }

    func addGitHubLink() {
        let dim: CGFloat = 24.0
        _gitHubNode = SKSpriteNode(imageNamed: "GitHub-Mark-120px-plus")
        _gitHubNode?.size = CGSize(width: dim, height: dim)
        let startPos = CGPoint(x: self.size.width + dim, y: dim)
        let endPos = CGPoint(x: self.size.width - dim, y: dim)
        _gitHubNode?.position = startPos
        _gitHubNode?.runAction(SKAction.moveTo(endPos, duration: 0.75))

        addChild(_gitHubNode!)
    }
}
