//
//  GameScene.swift
//  ArrowShooterUpgrade
//
//  Created by Mark on 9/25/19.
//  Copyright © 2019 Mark. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: IMAGE
    
    
    let targets = "target"
    let barrier = "barrier"
    let mainPlayerImg:String = "gun"
    let backgroundsImg = "bgr"
    let bullerImg = "bullet"
    
    let animPlusTwo = "plusTwo"
    let animPlusOne = "plusScore"
    let animMinusOne = "minusOne"
    
    var target:SKSpriteNode!
    var mainPlayer:SKSpriteNode!
    var enemy:SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var gameTimer:Timer!
    var score:Int = 0{
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let laserCategory:UInt32            = 0x1 << 0
    let targetCategory:UInt32           = 0x1 << 1
    let enemyCategory:UInt32            = 0x1 << 2
    
    override func sceneDidLoad() {
        
        
        setupGamePhysics()
        setupPlayer()
        setupBackGround()
        setupGameTimer()
        setupScoreLabel()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    // MARK: SETUP
    
    
    func setupGamePhysics() {
        self.physicsWorld.gravity           = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate        = self
    }
    func setupPlayer() {
        mainPlayer = SKSpriteNode(imageNamed: mainPlayerImg)
        mainPlayer.zPosition = 5
        mainPlayer.position = CGPoint(x: frame.midX , y: frame.minY+mainPlayer.size.height)
        mainPlayer.setScale(UIDevice.current.userInterfaceIdiom == .pad ? 2.0 : 1.0)
        
        self.addChild(mainPlayer)
        
        let moveAction = SKAction.move(to: CGPoint(x: frame.midX + 35, y: mainPlayer.position.y), duration: TimeInterval(2.0))
        let moveReverse = SKAction.move(to: CGPoint(x: frame.midX - 35 , y: mainPlayer.position.y), duration: TimeInterval(2.0))

        mainPlayer.run(SKAction.repeatForever(SKAction.sequence([moveAction, moveReverse])))
        
    }
    func setupBackGround() {
        let backgroundImg          = SKSpriteNode(imageNamed: backgroundsImg)
        backgroundImg.size         = CGSize(width: frame.width, height: frame.height)
        backgroundImg.position     = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(backgroundImg)
        backgroundImg.zPosition     = -1
    }
    
    func setupScoreLabel() {
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName     = "Marker-Felt"
        scoreLabel.fontSize     = 30
        scoreLabel.fontColor    = UIColor.red
        scoreLabel.position     = CGPoint(x: frame.midX, y: frame.maxY - scoreLabel.frame.size.height*2.5)
        scoreLabel.setScale(UIDevice.current.userInterfaceIdiom == .pad ? 2.0 : 1.0)
        scoreLabel.zPosition    = 1
        
        self.addChild(scoreLabel)
    }
    func setupGameTimer() {
        
        let randomInterval = Double.random(in: 6...10)
        gameTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(addTarget), userInfo: nil, repeats: true)
        gameTimer = Timer.scheduledTimer(timeInterval: randomInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    // MARK: ARROW
    
    
    func arrowDidCollideWithTarget(laser: SKSpriteNode, target: SKSpriteNode) {
        laser.removeFromParent()
        target.removeFromParent()
    }
    
    func checkContactPoint(contactPoint: CGPoint, target: SKSpriteNode) {
        let leftBorder = target.position.x - target.size.width * 0.25
        let rightBorder = target.position.x + target.size.width * 0.25
        if contactPoint.x > leftBorder && contactPoint.x < rightBorder {

            showHitLabel(contactPoint: contactPoint, isPerfect: true)
            score += 2
        } else {
            score += 1
            showHitLabel(contactPoint: contactPoint, isPerfect: false)
        }
    }
    
    // MARK: SCORE LABEL
    
    
    func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }
    
    //MARK: ANIMATION
    
    
    func showHitLabel(contactPoint: CGPoint, isPerfect: Bool) {
        let message = isPerfect ? SKEmitterNode(fileNamed: animPlusTwo) : SKEmitterNode(fileNamed: animPlusOne)
        message!.setScale(UIDevice.current.userInterfaceIdiom == .pad ? 2.0 : 1.0)
        message?.position = CGPoint(x: contactPoint.x - 30, y: contactPoint.y - 20)
        addChild(message!)
        let actionWait = SKAction.wait(forDuration: 0.4)
        let actionMoveDone = SKAction.removeFromParent()
        
        message!.run(SKAction.sequence([actionWait, actionMoveDone]))
    }
    
    // MARK: ARCHERY
    
    
    func archery() {
        
        let laser = SKSpriteNode(imageNamed: bullerImg)
        laser.position = mainPlayer.position
        
        laser.physicsBody = SKPhysicsBody(rectangleOf: laser.size)
        laser.physicsBody?.isDynamic = true
        laser.setScale(UIDevice.current.userInterfaceIdiom == .pad ? 2.0 : 1.0)
        
        laser.physicsBody?.categoryBitMask                  = laserCategory
        laser.physicsBody?.contactTestBitMask               = targetCategory | enemyCategory
        laser.physicsBody?.collisionBitMask                 = 0
        laser.physicsBody?.usesPreciseCollisionDetection    = true
        laser.name = "bullet"
        self.addChild(laser)
            
        //speed arrow
        let animationDuration:TimeInterval = 1
        
        var actions = [SKAction]()
        
    
        actions.append(SKAction.move(to: CGPoint(x: mainPlayer.position.x, y: frame.maxY+laser.size.height), duration: animationDuration))
        actions.append(SKAction.removeFromParent())
        
        laser.run(SKAction.sequence(actions))
        
    }
    
    // MARK: PHYSICS
    

    func didBegin(_ contact: SKPhysicsContact) {
           var firstBody: SKPhysicsBody
           var secondBody: SKPhysicsBody
           
           if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
               firstBody   = contact.bodyA
               secondBody  = contact.bodyB
           } else {
               firstBody   = contact.bodyB
               secondBody  = contact.bodyA
           }
           
           if (firstBody.categoryBitMask & targetCategory != 0) && (secondBody.categoryBitMask & laserCategory != 0) {
               if let target = firstBody.node as? SKSpriteNode, let arrow = secondBody.node as? SKSpriteNode {
                   checkContactPoint(contactPoint: contact.contactPoint, target: target)
                   arrowDidCollideWithTarget(laser: arrow, target: target)
                   collisionElements(arrowNode: arrow, targetNode: target)
                   updateScoreLabel()
                   
               }
           } else {
                   gameOver()
           }
           
       }
    
    func collisionElements (arrowNode:SKSpriteNode, targetNode: SKSpriteNode) {
            let hit         = SKEmitterNode(fileNamed: "hit")
            let arrowHit    = SKEmitterNode(fileNamed: "arrowHit")
        hit!.setScale(UIDevice.current.userInterfaceIdiom == .pad ? 2.0 : 1.0)
        arrowHit!.setScale(UIDevice.current.userInterfaceIdiom == .pad ? 2.0 : 1.0)


            hit?.position       = targetNode.position
            arrowHit?.position  = arrowNode.position
            

            self.addChild(hit!)
            self.addChild(arrowHit!)
            

            self.run(SKAction.wait(forDuration: 0.7)) {
                hit?.removeFromParent()
                arrowHit?.removeFromParent()
                

            }
            
        }
    
    override func didSimulatePhysics() {
        enumerateChildNodes(withName: "bullet") { (target, stop) in
            if target.position.y > self.frame.maxY {
                self.gameOver()
            }
        }
        
        enumerateChildNodes(withName: "target") { (target, stop) in
            let minusOne = SKEmitterNode(fileNamed: self.animMinusOne)
            
            if target.position.x > self.frame.maxX+20 {
                if self.score != 0{
                    target.removeFromParent()
                    self.score -= 1
                    self.updateScoreLabel()
                    minusOne!.position = CGPoint(x: target.position.x - 50, y: target.position.y)
                    self.addChild(minusOne!)
                    let actionWait = SKAction.wait(forDuration: 0.4)
                    let actionMoveDone = SKAction.removeFromParent()
                    
                    minusOne!.run(SKAction.sequence([actionWait, actionMoveDone]))
                }
            }
        }
    }
    
    // MARK: TARGETS
    
    
    @objc func addTarget () {
        target  = SKSpriteNode(imageNamed: targets)
        let randomPosition = GKRandomDistribution(lowestValue: Int(frame.minY+mainPlayer.frame.size.height*4),highestValue: Int(frame.maxY-mainPlayer.frame.size.height*3))
        let position = CGFloat(randomPosition.nextInt())
        target.position = CGPoint(x: UIScreen.main.bounds.minX-target.frame.width, y: position)
        target.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: target.size.width, height:       target.size.height/4))
        target.physicsBody?.isDynamic = true
        target.setScale(UIDevice.current.userInterfaceIdiom == .pad ? 2.0 : 1.0)
        target.zPosition = 3
        
    
        target.physicsBody?.categoryBitMask     = targetCategory
        target.physicsBody?.contactTestBitMask  = laserCategory
        
        target.physicsBody?.collisionBitMask = 0
        target.physicsBody?.usesPreciseCollisionDetection = true
    
    
        self.addChild(target)
    
        //speed target
        let animationDuration:TimeInterval = 6
        target.name = "target"
    
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: UIScreen.main.bounds.maxX+target.frame.width, y: position), duration:      animationDuration))
        
        actions.append(SKAction.removeFromParent())
        
    
        target.run(SKAction.sequence(actions))
           
       }
    
    @objc func createEnemy () {
        
        enemy  = SKSpriteNode(imageNamed: barrier)
        let randomPosition = GKRandomDistribution(lowestValue: Int(frame.minY+mainPlayer.frame.size.height*4), highestValue: Int(frame.maxY-mainPlayer.frame.size.height*3))
        let position = CGFloat(randomPosition.nextInt())
        enemy.position = CGPoint(x: UIScreen.main.bounds.maxX+enemy.frame.width, y: position)
        enemy.setScale(0.7)
        enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemy.size.width, height:       enemy.size.height/4))
        enemy.physicsBody?.isDynamic = true
        enemy.zPosition = 3
        enemy.setScale(UIDevice.current.userInterfaceIdiom == .pad ? 2.0 : 1.0)
        
    
        enemy.physicsBody?.categoryBitMask     = enemyCategory
        enemy.physicsBody?.contactTestBitMask  = laserCategory
        
        enemy.physicsBody?.collisionBitMask = 0
        enemy.physicsBody?.usesPreciseCollisionDetection = true
    
        self.addChild(enemy)
    
        //speed target
        let animationDuration:TimeInterval = 12
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: UIScreen.main.bounds.minX-enemy.frame.width, y: position), duration:       animationDuration))
        
        actions.append(SKAction.removeFromParent())
        
        enemy.run(SKAction.sequence(actions))
        
    }
    
    
    // MARK: GAME OVER
    
    
    func gameOver() {
        UserDefaults.standard.set(score, forKey: "Score")
            if score > UserDefaults.standard.integer(forKey: "Highscore") {
                UserDefaults.standard.set(score, forKey: "Highscore")
            }
    
        let gameScene = MenuScene(size: view!.bounds.size)
        let  transition = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
        view!.presentScene(gameScene,transition: transition)

    }
    
    // MARK: TOUCHES
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        archery()
    }
   
}
