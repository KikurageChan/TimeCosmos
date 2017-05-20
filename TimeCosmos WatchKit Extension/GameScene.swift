//
//  GameScene.swift
//  TimeCosmos
//
//  Created by 木耳ちゃん on 2017/03/13.
//  Copyright © 2017年 KikurageChan. All rights reserved.
//

import Foundation
import SpriteKit
import WatchKit

struct CollisionType {
    static let player: UInt32 = 1 << 0
    static let PlayerBullet: UInt32 = 1 << 1
    static let enemy: UInt32 = 1 << 2
    static let none: UInt32 = 1 << 3
}

class GameScene: SKScene {
    
    var gameEngine: SKSpriteNode!
    var playerNode: SKSpriteNode!
    var scoreNode: SKLabelNode!
    var bombTextureNames: [String] = ["bomb0", "bomb1", "bomb2"]
    var bombTextures: [SKTexture] = []
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        //シーン(ワールド)の設定
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        for bombTextureName in bombTextureNames {
            let texture = SKTexture(imageNamed: bombTextureName)
            bombTextures.append(texture)
        }
        
        let backgroundTexture = SKTexture(imageNamed: "Background")
        let backgroundMoveAction = SKAction.moveBy(x: 0, y: -frame.size.height, duration: 5)
        let backgroundResetAction = SKAction.moveBy(x: 0, y: frame.size.height, duration: 0)
        let backgroundAction = SKAction.repeatForever(SKAction.sequence([backgroundMoveAction, backgroundResetAction]))
        
        for i in 0 ..< 3 {
            let backgroundNode = SKSpriteNode(texture: backgroundTexture)
            backgroundNode.size = CGSize(width: size.width, height: size.height)
            backgroundNode.zPosition = -10
            backgroundNode.position = CGPoint(x: size.width * 0.5, y: CGFloat(i) * backgroundNode.size.height)
            addChild(backgroundNode)
            backgroundNode.run(backgroundAction)
            
        }
        gameEngine = childNode(withName: "GameEngine") as! SKSpriteNode
        playerNode = childNode(withName: "Player") as! SKSpriteNode
        scoreNode = childNode(withName: "Score") as! SKLabelNode
        
        //プレイヤーNode
        playerNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: 16))
        playerNode.physicsBody?.categoryBitMask = CollisionType.player
        playerNode.physicsBody?.isDynamic = false
        playerNode.physicsBody?.contactTestBitMask = CollisionType.enemy
        playerNode.position = CGPoint(x: frame.size.width * 0.5, y: playerNode.size.height * 2.5)
        playerNode.zPosition = 10
        //ロックオンNode
        let lockOnNode = SKSpriteNode(imageNamed: "LockON")
        lockOnNode.setScale(3)
        lockOnNode.zPosition = 10
        lockOnNode.position = CGPoint(x: 0, y: size.height * 1.5)
        playerNode.addChild(lockOnNode)
        //バレットNode
        let bulletTexture = SKTexture(imageNamed: "Bullet")
        let bulletCreateAction = SKAction.run {
            let bulletNode = SKSpriteNode(texture: bulletTexture)
            bulletNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2, height: 6))
            bulletNode.physicsBody?.categoryBitMask = CollisionType.PlayerBullet
            bulletNode.zPosition = 9
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
            enemyNode.physicsBody?.contactTestBitMask = CollisionType.player | CollisionType.PlayerBullet
            enemyNode.position.x = CGFloat(Int.createRandom(Int(self.frame.size.width) - Int(enemyNode.size.width * 0.5)) + Int(enemyNode.size.width * 0.5))
            enemyNode.position.y = self.frame.size.height + enemyNode.size.height * 0.5
            let moveDwonAction = SKAction.moveBy(x: 0, y: -self.size.height * 1.5, duration: 10)
            self.addChild(enemyNode)
            enemyNode.run(moveDwonAction, completion: {
                enemyNode.removeFromParent()
            })
        }
        gameEngine.run(SKAction.repeatForever(SKAction.sequence([enemyCreateAction, SKAction.wait(forDuration: 1)])))
    }
    
    func panAction(_ point: CGPoint) {
        if point.x <= frame.origin.x + (playerNode.size.width * 0.5) || point.x >= size.width - (playerNode.size.width * 0.5) { return }
        playerNode.position.x = point.x
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        let bombAnimation = SKAction.animate(with: bombTextures, timePerFrame: 0.1)
        //bodyAがEnemyの場合
        if contact.bodyA.categoryBitMask == CollisionType.enemy && contact.bodyB.categoryBitMask == CollisionType.PlayerBullet {
            removeChildren(in: [nodeB])
            contact.bodyA.contactTestBitMask = CollisionType.none
            contact.bodyA.node?.run(bombAnimation, completion: {
                self.removeChildren(in: [nodeA])
            })
        } else if contact.bodyB.categoryBitMask == CollisionType.enemy && contact.bodyA.categoryBitMask == CollisionType.PlayerBullet {
            removeChildren(in: [nodeA])
            contact.bodyB.contactTestBitMask = CollisionType.none
            contact.bodyB.node?.run(bombAnimation, completion: {
                self.removeChildren(in: [nodeB])
            })
        }
    }
}
