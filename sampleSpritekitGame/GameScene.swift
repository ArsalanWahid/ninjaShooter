//
//  GameScene.swift
//  sampleSpritekitGame
//
//  Created by Arsalan Wahid Asghar on 1/9/18.
//  Copyright © 2018 Arsalan Wahid Asghar. All rights reserved.
//

import SpriteKit

//The Magic of Math - Study
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

//MARK:- Physics Body Categories
struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1 binary form
    static let Projectile: UInt32 = 0b10      // 2 binary form
}





//MARK:- GameScene
class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var count = 0
    var monsterKilled = 0
    
    //Make player object and handles allt he
    let player  = SKSpriteNode(imageNamed: "player")
    let projectileLabel = SKLabelNode(fontNamed: "Chalkduster")
    let mosterkilledLabel = SKLabelNode(fontNamed: "Chalkduster")
    let projectileCount = SKLabelNode(fontNamed: "Chalkduster")
    let monstersKilledCount = SKLabelNode(fontNamed: "Chalkduster")
    
    override func didMove(to view: SKView) {
        
        //Set BackGround Music
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        //Set labels
        
        projectileLabel.position = CGPoint(x: self.size.width / 4 - 100, y: self.frame.size.height/4 - 80)
        projectileLabel.text = "Projectile Used:"
        projectileLabel.fontSize = 10
        projectileLabel.fontColor = .black
        addChild(projectileLabel)
        
        projectileCount.position = CGPoint(x: self.size.width / 4 - 50, y: self.frame.size.height/4 - 80)
        projectileCount.text = "\(count)"
        projectileCount.fontColor = .black
        projectileCount.fontSize = 10
        addChild(projectileCount)
        
        
        mosterkilledLabel.position = CGPoint(x: self.size.width / 4 + 10, y: self.frame.size.height/4 - 80)
        mosterkilledLabel.text = "Monsters Killed:"
        mosterkilledLabel.fontSize = 10
        mosterkilledLabel.fontColor = .black
        addChild(mosterkilledLabel)
        
        monstersKilledCount.position = CGPoint(x: self.size.width / 4 + 60, y: self.frame.size.height/4 - 80)
        monstersKilledCount.text = ""
        monstersKilledCount.fontSize = 10
        monstersKilledCount.fontColor = .black
        addChild(monstersKilledCount)
        
        //Setup Physics
        //no gravity
        physicsWorld.gravity = CGVector.zero
        
        //Intern will recieve events that boss delegate has defined
        physicsWorld.contactDelegate = self
        
        
        backgroundColor = .white
        player.position = CGPoint(x: self.size.width * 0.1, y: self.size.height * 0.5)
        addChild(player)
        //A sequence Actions that spawns a new monster every one second.
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: 1.0, withRange: 3)
                ])
        ))
    }
    
    //MARK:- Collision Detection function - Study
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode, let
                projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
        
    }
    
    
    //MARK:- Helper Functions
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    //Helper function
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        print("Hit")
        monsterKilled += 1
        projectile.removeFromParent()
        monster.removeFromParent()
    }
    
    
    //MARK:- Add monster
    func addMonster() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "monster")
        
        //Set Physics Properties
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        
        //setup monster category
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        
        // contact when hitting monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        
        // Don't bounce off anything
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: self.size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        //Sequence actions that moves monster to specifed location and once location is reached removed
        //monster from the node tree
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    
    //MARK:- Shoot Projectiles - Study
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
        //Play Audiofile
        run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        print("Player Touched here \(touchLocation)")
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        print("The initial ProjectTile Position: \(projectile.position)")
        count += 1
        //Set up physics of the Projectile
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width / 2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        print("Offset : \(offset)")
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        print("Direction to shoot \(direction)")
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        projectileCount.text = "\(count)"
        monstersKilledCount.text = "\(monsterKilled)"
    }
    
    
}
