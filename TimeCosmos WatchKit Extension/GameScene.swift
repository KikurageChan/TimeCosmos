//
//  GameScene.swift
//  TimeCosmos
//
//  Created by 木耳ちゃん on 2017/03/13.
//  Copyright © 2017年 KikurageChan. All rights reserved.
//

import SpriteKit
import WatchKit

struct CollisionType {
    static let none: UInt32 = 1 << 0
    static let player: UInt32 = 1 << 1
    static let PlayerBullet: UInt32 = 1 << 2
    static let enemy: UInt32 = 1 << 3
}

struct ZPositionType {
    static let background: CGFloat = -10
    static let node: CGFloat = 1
    static let ui: CGFloat = 10
}

class GameScene: SKScene {
    
    var gameEngine: SKSpriteNode!
    var playerNode: SKSpriteNode!
    var scoreNode: SKLabelNode!
    var gameOverNode: SKLabelNode!
    var bombTextureNames: [String] = ["bomb0", "bomb1", "bomb2"]
    var bombTextures: [SKTexture] = []
    
    var score = 0 {
        didSet {
            scoreNode.text = "Score: \(score)"
        }
    }
    var isGameOver = false
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        for bombTextureName in bombTextureNames {
            let texture = SKTexture(imageNamed: bombTextureName)
            bombTextures.append(texture)
        }
        
        //背景のテクスチャを設定
        let backgroundTexture = SKTexture(imageNamed: "Background")
        let backgroundMoveAction = SKAction.moveBy(x: 0, y: -frame.size.height, duration: 5)
        let backgroundResetAction = SKAction.moveBy(x: 0, y: frame.size.height, duration: 0)
        let backgroundAction = SKAction.repeatForever(SKAction.sequence([backgroundMoveAction, backgroundResetAction]))
        
        for i in 0 ..< 3 {
            let backgroundNode = SKSpriteNode(texture: backgroundTexture)
            print(size)
            backgroundNode.size = CGSize(width: size.width, height: size.height)
            backgroundNode.zPosition = ZPositionType.background
            backgroundNode.position = CGPoint(x: size.width * 0.5, y: CGFloat(i) * backgroundNode.size.height)
            addChild(backgroundNode)
            backgroundNode.run(backgroundAction)
        }
        //sksファイルからNodeを取得
        gameEngine = childNode(withName: "GameEngine") as! SKSpriteNode
        playerNode = childNode(withName: "Player") as! SKSpriteNode
        scoreNode = childNode(withName: "Score") as! SKLabelNode
        gameOverNode = childNode(withName: "GameOver") as! SKLabelNode
        //プレイヤーNode
        playerNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: 16))
        playerNode.physicsBody?.categoryBitMask = CollisionType.player
        playerNode.physicsBody?.collisionBitMask = CollisionType.none
        playerNode.position = CGPoint(x: frame.size.width * 0.5, y: playerNode.size.height * 2)
        playerNode.zPosition = ZPositionType.node
        //ロックオンNode
        let lockOnNode = SKSpriteNode(imageNamed: "LockON")
        lockOnNode.setScale(3)
        lockOnNode.zPosition = ZPositionType.node
        lockOnNode.position = CGPoint(x: 0, y: size.height * 1.5)
        playerNode.addChild(lockOnNode)
        //バレットNode
        let bulletTexture = SKTexture(imageNamed: "Bullet")
        let bulletCreateAction = SKAction.run {
            let bulletNode = SKSpriteNode(texture: bulletTexture)
            bulletNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2, height: 6))
            bulletNode.physicsBody?.categoryBitMask = CollisionType.PlayerBullet
            bulletNode.zPosition = ZPositionType.node
            bulletNode.position = CGPoint(x: self.playerNode.position.x, y: self.playerNode.position.y + self.playerNode.size.height * 0.5)
            let moveUpAction = SKAction.moveBy(x: 0, y: self.size.height * 1.5, duration: 0.8)
            self.addChild(bulletNode)
            bulletNode.run(moveUpAction, completion: {
                bulletNode.removeFromParent()
            })
        }
        playerNode.run(SKAction.repeatForever(SKAction.sequence([bulletCreateAction, SKAction.wait(forDuration: 0.3)])))
        //エネミーNode
        let enemyTexture = SKTexture(imageNamed: "Enemy1")
        let enemyCreateAction = SKAction.run {
            let enemyNode = SKSpriteNode(texture: enemyTexture)
            enemyNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 13, height: 12))
            enemyNode.physicsBody?.categoryBitMask = CollisionType.enemy
            enemyNode.physicsBody?.collisionBitMask = CollisionType.none
            enemyNode.physicsBody?.contactTestBitMask = CollisionType.player | CollisionType.PlayerBullet
            enemyNode.position.x = CGFloat(Int.createRandom(Int(self.frame.size.width) - Int(enemyNode.size.width * 0.5)) + Int(enemyNode.size.width * 0.5))
            enemyNode.position.y = self.frame.size.height + enemyNode.size.height * 0.5
            let moveDwonAction = SKAction.moveBy(x: 0, y: -self.size.height * 1.5, duration: 10)
            self.addChild(enemyNode)
            enemyNode.run(moveDwonAction, completion: {
                enemyNode.removeFromParent()
            })
        }
        gameEngine.isHidden = true
        gameEngine.run(SKAction.repeatForever(SKAction.sequence([enemyCreateAction, SKAction.wait(forDuration: 1)])))
    }
    
    func panAction(_ point: CGPoint) {
        if isGameOver { return }
        if point.x <= frame.origin.x + (playerNode.size.width * 0.5) || point.x >= size.width - (playerNode.size.width * 0.5) { return }
        playerNode.position.x = point.x
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        let bombAnimation = SKAction.animate(with: bombTextures, timePerFrame: 0.1)
        if contact.bodyA.categoryBitMask == CollisionType.enemy && contact.bodyB.categoryBitMask == CollisionType.PlayerBullet {
            removeChildren(in: [nodeB])
            contact.bodyA.contactTestBitMask = CollisionType.none
            contact.bodyA.node?.run(bombAnimation, completion: {
                self.removeChildren(in: [nodeA])
            })
            score += 1
        } else if contact.bodyB.categoryBitMask == CollisionType.enemy && contact.bodyA.categoryBitMask == CollisionType.PlayerBullet {
            removeChildren(in: [nodeA])
            contact.bodyB.contactTestBitMask = CollisionType.none
            contact.bodyB.node?.run(bombAnimation, completion: {
                self.removeChildren(in: [nodeB])
            })
            score += 1
        }
        if contact.bodyA.categoryBitMask == CollisionType.enemy && contact.bodyB.categoryBitMask == CollisionType.player ||
                contact.bodyB.categoryBitMask == CollisionType.enemy && contact.bodyA.categoryBitMask == CollisionType.player {
            gameOverNode.position = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
            gameOverNode.zPosition = ZPositionType.ui
            gameOverNode.isHidden = false
            self.isPaused = true
            isGameOver = true
        }
    }
}
