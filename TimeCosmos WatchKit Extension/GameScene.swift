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

enum ButtonType {
    case left
    case right
    case fire
}

class GameScene: SKScene {
    
    var isLeftPressed = false
    var isRightPressed = false
    var playerNode: SKSpriteNode!
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        playerNode = childNode(withName: "Player") as! SKSpriteNode!
        playerNode.position = CGPoint(x: frame.size.width * 0.5, y: playerNode.size.height * 2.5)
        playerNode.zPosition = 10
        
        let bulletCreateAction = SKAction.run {
            let bulletNode = SKSpriteNode(imageNamed: "Bullet")
            bulletNode.zPosition = 9
            bulletNode.position = CGPoint(x: self.playerNode.position.x, y: self.playerNode.position.y + self.playerNode.size.height * 0.5)
            let bulletUpAction = SKAction.moveBy(x: 0, y: self.frame.size.height * 1.5, duration: 0.8)
            self.addChild(bulletNode)
            bulletNode.run(bulletUpAction, completion: {
                bulletNode.removeFromParent()
            })
        }
        let delayAction = SKAction.wait(forDuration: 0.3)
        playerNode.run(SKAction.repeatForever(SKAction.sequence([bulletCreateAction, delayAction])))
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isLeftPressed && playerNode.position.x - (playerNode.size.width * 0.5) >= frame.origin.x {
            playerNode.position.x -= 2
        }
        if isRightPressed && playerNode.position.x <= size.width - (playerNode.size.width * 0.5) {
            playerNode.position.x += 2
        }
    }
    
    func action(buttonType: ButtonType) {
        switch buttonType {
        case .left:
            isLeftPressed = true
            isRightPressed = false
        case .right:
            isRightPressed = true
            isLeftPressed = false
        case .fire:
            let bulletNode = SKSpriteNode(imageNamed: "Bullet")
            bulletNode.zPosition = 9
            bulletNode.position = CGPoint(x: playerNode.position.x, y: playerNode.position.y + playerNode.size.height * 0.5)
            let bulletUpAction = SKAction.moveBy(x: 0, y: frame.size.height * 1.5, duration: 0.8)
            addChild(bulletNode)
            bulletNode.run(bulletUpAction, completion: {
                bulletNode.removeFromParent()
            })
        }
    }
    
    func tapAction(_ point: CGPoint) {
        if playerNode.position.x - (playerNode.size.width * 0.5) >= frame.origin.x {
            playerNode.position.x -= 2
        }
        playerNode.position.x = point.x
    }
    
    func panAction(_ point: CGPoint) {
        if point.x <= frame.origin.x + (playerNode.size.width * 0.5) || point.x >= size.width - (playerNode.size.width * 0.5) {
            return
        }
        playerNode.position.x = point.x
    }
    
}
