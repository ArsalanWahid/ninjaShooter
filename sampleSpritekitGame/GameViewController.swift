//
//  GameViewController.swift
//  sampleSpritekitGame
//
//  Created by Arsalan Wahid Asghar on 1/9/18.
//  Copyright © 2018 Arsalan Wahid Asghar. All rights reserved.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the scene size to the root view bounds
        let gameScene =  GameScene(size: view.bounds.size)
        let SkView = view as! SKView
        SkView.showsFPS = true
        SkView.showsNodeCount = true
        SkView.ignoresSiblingOrder = true
        gameScene.scaleMode = .resizeFill
                
        //Finally after setup game scene is present in SKView
        SkView.presentScene(gameScene)
    }

    
    
    //Hides the narrow status bar window on top
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
}
