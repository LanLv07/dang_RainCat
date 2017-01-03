//
//  BackgroundNode.swift
//  RainCat
//
//  Created by alan on 17/1/2.
//  Copyright © 2017年 Thirteen23. All rights reserved.
//

import Foundation
import SpriteKit

public class BackgroundNode : SKNode {
    
    public func setup(size : CGSize) {
        let yPos : CGFloat = size.height * 0.10
        let startPoint = CGPoint(x: 0, y: yPos)
        let endPoint = CGPoint(x: size.width, y: yPos)
        
        physicsBody = SKPhysicsBody(edgeFrom: startPoint, to: endPoint)
        
        //创建天空实例
        let skyNode = SKShapeNode(rect: CGRect(origin: CGPoint(), size: size))
        skyNode.fillColor = SKColor(red:0.38, green:0.60, blue:0.65, alpha:1.0)
        skyNode.strokeColor = SKColor.clear
        skyNode.zPosition = 0
        
        let groundSize = CGSize(width: size.width, height: size.height * 0.35)
        //创建地面实例
        let groundNode = SKShapeNode(rect: CGRect(origin: CGPoint(), size: groundSize))
        groundNode.fillColor = SKColor(red:0.99, green:0.92, blue:0.55, alpha:1.0)
        groundNode.strokeColor = SKColor.clear
        groundNode.zPosition = 1
        
        addChild(skyNode)
        addChild(groundNode)
        
        physicsBody?.restitution = 0.3
        physicsBody?.categoryBitMask = FloorCategory //将物理实体更新为floorCategory
        physicsBody?.contactTestBitMask = RainDropCategory  //使地面物理实体是可触碰的
    }
}
