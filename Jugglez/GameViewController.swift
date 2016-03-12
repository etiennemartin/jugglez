//
//  GameViewController.swift
//  Jugglez
//
//  Created by Etienne Martin on 2015-01-18.
//  Copyright (c) 2015 Etienne Martin. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = IntroScene(size: view.bounds.size)
        scene.scaleMode = .ResizeFill

        if let skView = view as? SKView {
            skView.ignoresSiblingOrder = true
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            skView.presentScene(scene)
        }

        // Register for GameCenter event
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "onGameCenterViewRequired:",
            name: GameCenterManager.presentGameCenterNotificationViewController,
            object: nil)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    internal func onGameCenterViewRequired(notification: NSNotification) {
        if GameCenterManager.sharedInstance.authViewController != nil {
            self.presentViewController(GameCenterManager.sharedInstance.authViewController!, animated: true, completion: nil)
        }
    }
}
