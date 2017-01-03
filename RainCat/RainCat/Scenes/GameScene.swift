//
//  GameScene.swift
//  RainCat
//
//  Created by Marc Vandehey on 8/29/16.
//  Copyright © 2016 Thirteen23. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

  private var lastUpdateTime : TimeInterval = 0
  private var currentRainDropSpawnTime : TimeInterval = 0
  private var rainDropSpawnRate : TimeInterval = 0.5
  private let umbrellaNode = UmbrellaSprite.newInstance()
    
  let raindropTexture = SKTexture(imageNamed: "rain_drop")

  private let backgroundNode = BackgroundNode()

  override func sceneDidLoad() {
    self.lastUpdateTime = 0
    backgroundNode.setup(size: size)
    addChild(backgroundNode)
    
    //加入全局边界
    var worldFrame = frame
    worldFrame.origin.x -= 100
    worldFrame.origin.y -= 100
    worldFrame.size.height += 200
    worldFrame.size.width += 200
    
    self.physicsBody = SKPhysicsBody(edgeLoopFrom: worldFrame)
    self.physicsBody?.categoryBitMask = WorldCategory
    
    //将雨伞放置在屏幕中央
    //umbrellaNode.position = CGPoint(x: frame.midX, y: frame.midY)
    //重新设置雨伞的初始位置和终点
    umbrellaNode.updatePosition(point: CGPoint(x: frame.midX, y: frame.midY))
    
    umbrellaNode.zPosition = 4
    addChild(umbrellaNode)
    
    //监听physicsWorld中发生的碰撞
    self.physicsWorld.contactDelegate = self
    
  }


  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touchPoint = touches.first?.location(in: self)
    
    if let point = touchPoint {
        umbrellaNode.setDestination(destination: point)
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touchPoint = touches.first?.location(in: self)
    
    if let point = touchPoint {
        umbrellaNode.setDestination(destination: point)
    }
  }

  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered

    // Initialize _lastUpdateTime if it has not already been
    if (self.lastUpdateTime == 0) {
      self.lastUpdateTime = currentTime
    }

    // Calculate time since last update
    let dt = currentTime - self.lastUpdateTime

  
    // Update the spawn timer   每次累加的时间差大于rainDropSpawnRate的时候，新建一个雨滴
    currentRainDropSpawnTime += dt
    
    if currentRainDropSpawnTime > rainDropSpawnRate {
        currentRainDropSpawnTime = 0
        spawnRaindrop()
    }

    self.lastUpdateTime = currentTime
    
    //通知雨伞进行更新
    umbrellaNode.update(deltaTime: dt)
  }
    
  private func spawnRaindrop() {
        let raindrop = SKSpriteNode(texture: raindropTexture)
        raindrop.physicsBody = SKPhysicsBody(texture: raindropTexture, size: raindrop.size)
    
        raindrop.physicsBody?.categoryBitMask = RainDropCategory
        raindrop.physicsBody?.contactTestBitMask = FloorCategory | WorldCategory
    
        //创建雨滴之后，随机化雨滴掉落的位置
        let xPosition =
            CGFloat(arc4random()).truncatingRemainder(dividingBy: size.width)
        let yPosition = size.height + raindrop.size.height
    
        //保证坐标在屏幕范围内
        raindrop.position = CGPoint(x: xPosition, y: yPosition)
    
        raindrop.zPosition = 2
        
        addChild(raindrop)
  }
    
  func didBegin(_ contact: SKPhysicsContact) { //每当带有我们预先设置的contactTestBitMasks的物体碰撞发生时,这个方法就会被调用
        if (contact.bodyA.categoryBitMask == RainDropCategory) {
            contact.bodyA.node?.physicsBody?.collisionBitMask = 0
            contact.bodyA.node?.physicsBody?.categoryBitMask = 0
        } else if (contact.bodyB.categoryBitMask == RainDropCategory) {
            contact.bodyB.node?.physicsBody?.collisionBitMask = 0
            contact.bodyB.node?.physicsBody?.categoryBitMask = 0
        }
    
        //加入销毁操作
        if contact.bodyA.categoryBitMask == WorldCategory {
            contact.bodyB.node?.removeFromParent()
            contact.bodyB.node?.physicsBody = nil
            contact.bodyB.node?.removeAllActions()
        } else if contact.bodyB.categoryBitMask == WorldCategory {
            contact.bodyA.node?.removeFromParent()
            contact.bodyA.node?.physicsBody = nil
            contact.bodyA.node?.removeAllActions()
        }
    }
    
}
