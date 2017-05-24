//
//  InterfaceController.swift
//  TimeCosmos WatchKit Extension
//
//  Created by 木耳ちゃん on 2017/03/13.
//  Copyright © 2017年 KikurageChan. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet var skInterface: WKInterfaceSKScene!
    
    var scene: GameScene?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let gameScene = GameScene(fileNamed: "GameScene") {
            scene = gameScene
            scene?.scaleMode = .aspectFill
            skInterface.presentScene(gameScene)
        }
    }
    
    @IBAction func panHandle(_ sender: WKPanGestureRecognizer) {
        let point = sender.locationInView()
        scene?.panAction(point)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

extension WKGestureRecognizer {
    //シーンのアンカーポイントはデフォルトの(x: 0, y: 0)を利用
    func locationInView() -> CGPoint {
        let location = locationInObject()
        let bounds = objectBounds()
        return CGPoint(x: location.x, y: bounds.maxY - location.y)
    }
}
