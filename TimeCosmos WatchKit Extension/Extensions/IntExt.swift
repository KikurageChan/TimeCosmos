//
//  IntExt.swift
//  TimeCosmos
//
//  Created by 木耳ちゃん on 2017/03/16.
//  Copyright © 2017年 KikurageChan. All rights reserved.
//

import Foundation

public extension Int {
    
    static func createRandom(_ num: Int) -> Int {
        return Int(arc4random_uniform(UInt32(num)))
    }
}
