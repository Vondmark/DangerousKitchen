//
//  MenuScene.swift
//  ArrowShooterUpgrade
//
//  Created by Mark on 9/26/19.
//  Copyright © 2019 Mark. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    let bgrImg = "bgr"
    
    override func didMove(to view: SKView) {
        setupBackground()
        addLabels()
    }
    
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: bgrImg)
        background.alpha = 0.8
        background.size = CGSize(width: frame.width, height: frame.height)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(background)
        
        
    }

    func addLabels() {
        let playLabel = SKLabelNode(text: "Tap to Play!")
        playLabel.fontName = "Arial-BoldMT"
        playLabel.fontSize = 55.0
        playLabel.fontColor = .red
        playLabel.alpha = 1
        playLabel.zPosition = 2
        playLabel.position = CGPoint(x: frame.midX, y: frame.midY+playLabel.frame.size.height)
        addChild(playLabel)
        animate(label: playLabel)
        
        let highScorelabel = SKLabelNode(text: "Highscore: " + "\(UserDefaults.standard.integer(forKey: "Highscore"))")
        highScorelabel.fontName = "Arial-BoldMT"
        highScorelabel.fontSize = 40.0
        highScorelabel.fontColor = .red
        highScorelabel.alpha = 1
        highScorelabel.zPosition = 2
        highScorelabel.position = CGPoint(x: frame.midX, y: frame.minY + playLabel.frame.size.height)
        addChild(highScorelabel)
        
        let recentScoreLabel = SKLabelNode(text: "Score: " + "\(UserDefaults.standard.integer(forKey: "Score"))")
        recentScoreLabel.fontName = "Arial-BoldMT"
        recentScoreLabel.fontSize = 40.0
        recentScoreLabel.fontColor = .red
        recentScoreLabel.alpha = 1
        recentScoreLabel.zPosition = 2
        recentScoreLabel.position = CGPoint(x: frame.midX, y: frame.minY + playLabel.frame.size.height+highScorelabel.frame.size.height)
        addChild(recentScoreLabel)
        
    }

    func animate(label: SKLabelNode) {
        
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)

            //another way to animate Play logo!
    //        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
    //        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
            
            
            let sequence = SKAction.sequence([fadeOut, fadeIn])
            label.run(SKAction.repeatForever(sequence))
        }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(size: view!.bounds.size)
        let  transition = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
        view!.presentScene(gameScene,transition: transition)
    }
    
}




