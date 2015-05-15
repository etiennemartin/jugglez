//
//  Button.swift
//  Jugglez
//
//  Created by Etienne Martin on 2015-03-14.
//  Copyright (c) 2015 Etienne Martin. All rights reserved.
//

import SpriteKit

class Button : SKShapeNode {
    
    init(size: CGSize, position: CGPoint, text: String) {
        let frame : CGRect = CGRectMake(position.x, position.y, size.width, size.height)
        super.init()
        bootstrapInit(frame, text:text)
    }

    init (frame: CGRect, text: String) {
        super.init()
        bootstrapInit(frame, text:text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bootstrapInit(frame: CGRect, text: String) {
        
        var cornerRadius : CGFloat = 10
        var shadowOffset : CGFloat = 2
        
        _button = SKShapeNode(rect: frame, cornerRadius: cornerRadius)
        _button.strokeColor = SKColor.themeLightBackgroundColor()
        _button.fillColor = SKColor.themeLightBackgroundColor()
        
        var shadow = SKShapeNode(rect: frame, cornerRadius: cornerRadius)
        shadow.strokeColor = _shadowColor
        shadow.fillColor = _shadowColor
        shadow.position.x += shadowOffset
        shadow.position.y -= shadowOffset
        
        _label = SKLabelNode(text: text)
        _label.fontName = SKLabelNode.defaultFontName()
        _label.fontSize = 30
        _label.fontColor = SKColor.themeDarkFontColor()
        _label.position = CGPointMake(_button.frame.size.width / 2, _button.frame.size.height / 4)
        
        addChild(shadow)
        addChild(_button)
        _button.addChild(_label)
        
        calculateAccumulatedFrame()
    }
    
    var foregroundColor : SKColor {
        get {
            return _button.fillColor
        }
        set(value) {
            _button.fillColor = value
            _button.strokeColor = value
        }
    }
    
    var textColor : SKColor {
        get {
            return _label.fontColor
        }
        set (value) {
            _label.fontColor = value
        }
    }
    
    private var _button : SKShapeNode = SKShapeNode()
    private var _label : SKLabelNode = SKLabelNode()
    private let _shadowColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.20)
}