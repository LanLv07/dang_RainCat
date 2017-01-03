//
//  UmbrellaSprite.swift
//  RainCat
//
//  Created by alan on 17/1/2.
//  Copyright © 2017年 Thirteen23. All rights reserved.
//

import Foundation
import SpriteKit

public class UmbrellaSprite : SKSpriteNode {
    private var destination : CGPoint!   //保证对象移动的终点位置
    private let easing : CGFloat = 0.1
    
    public static func newInstance() -> UmbrellaSprite {
        let umbrella = UmbrellaSprite(imageNamed: "umbrella")
        
        let path = UIBezierPath()
        path.move(to: CGPoint())
        path.addLine(to: CGPoint(x: -umbrella.size.width / 2 - 30, y: 0))
        path.addLine(to: CGPoint(x: 0, y: umbrella.size.height / 2))
        path.addLine(to: CGPoint(x: umbrella.size.width / 2 + 30, y: 0))
        
        umbrella.physicsBody = SKPhysicsBody(polygonFrom: path.cgPath)
        umbrella.physicsBody?.isDynamic = false
        umbrella.physicsBody?.restitution = 0.9
        
        return umbrella
    }
    
    public func updatePosition(point : CGPoint) {
        position = point
        destination = point
    }
    
    //缓冲雨伞的移动
    public func setDestination(destination : CGPoint) {
        self.destination = destination
    }
    
    public func update(deltaTime : TimeInterval) {
        let distance = sqrt(pow((destination.x - position.x), 2) + pow((destination.y - position.y), 2))
        
        if(distance > 1) {
            let directionX = (destination.x - position.x)
            let directionY = (destination.y - position.y)
            
            position.x += directionX * easing
            position.y += directionY * easing
        } else {
            position = destination;
        }
    }
}
