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
  private let foodEdgeMargin : CGFloat = 75.0
  private let umbrellaNode = UmbrellaSprite.newInstance()
  private var catNode : CatSprite! //!告诉编译器，它并不需要在 init 语句中立即初始化，而且它应该不会是 nil
  private var foodNode : FoodSprite!
    
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
    
    spawnCat()
    
    spawnFood()
    
    
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
    
    catNode.update(deltaTime: dt, foodLocation: foodNode.position)
  }
    
  private func spawnRaindrop() {
        let raindrop = SKSpriteNode(texture: raindropTexture)
        raindrop.physicsBody = SKPhysicsBody(texture: raindropTexture, size: raindrop.size)
    
        raindrop.physicsBody?.density = 0.5
    
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
    
  func spawnCat() {
        if let currentCat = catNode, children.contains(currentCat) {
            catNode.removeFromParent()
            catNode.removeAllActions()
            catNode.physicsBody = nil
        }
        
        catNode = CatSprite.newInstance()
        catNode.position = CGPoint(x: umbrellaNode.position.x, y: umbrellaNode.position.y - 30)
        
        addChild(catNode)
  }
    
  func spawnFood() {
        if let currentFood = foodNode, children.contains(currentFood) {
            foodNode.removeFromParent()
            foodNode.removeAllActions()
            foodNode.physicsBody = nil
        }
        foodNode = FoodSprite.newInstance()
        var randomPosition : CGFloat = CGFloat(arc4random())
        randomPosition = randomPosition.truncatingRemainder(dividingBy: size.width - foodEdgeMargin * 2)
        randomPosition += foodEdgeMargin
        
        foodNode.position = CGPoint(x: randomPosition, y: size.height)
        
        addChild(foodNode)
  }
    
  func didBegin(_ contact: SKPhysicsContact) { //每当带有我们预先设置的contactTestBitMasks的物体碰撞发生时,这个方法就会被调用
        if (contact.bodyA.categoryBitMask == RainDropCategory) {
            contact.bodyA.node?.physicsBody?.collisionBitMask = 0
            contact.bodyA.node?.physicsBody?.categoryBitMask = 0
        } else if (contact.bodyB.categoryBitMask == RainDropCategory) {
            contact.bodyB.node?.physicsBody?.collisionBitMask = 0
            contact.bodyB.node?.physicsBody?.categoryBitMask = 0
        }
    
        if contact.bodyA.categoryBitMask == FoodCategory || contact.bodyB.categoryBitMask == FoodCategory {
            handleFoodHit(contact: contact)
            return
        }
    
        if contact.bodyA.categoryBitMask == CatCategory || contact.bodyB.categoryBitMask == CatCategory {
            handleCatCollision(contact: contact)
            
            return
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
    
  func handleCatCollision(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == CatCategory {
            otherBody = contact.bodyB
        } else {
            otherBody = contact.bodyA
        }
        
        switch otherBody.categoryBitMask {
        case RainDropCategory:
            catNode.hitByRain()
        case WorldCategory:
            spawnCat()
        default:
            print("Something hit the cat")
        }
  }
    
  func handleFoodHit(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        var foodBody : SKPhysicsBody
        
        if(contact.bodyA.categoryBitMask == FoodCategory) {
            otherBody = contact.bodyB
            foodBody = contact.bodyA
        } else {
            otherBody = contact.bodyA
            foodBody = contact.bodyB
        }
        
        switch otherBody.categoryBitMask {
        case CatCategory:
            //TODO increment points
            print("fed cat")
            fallthrough
        case WorldCategory:
            foodBody.node?.removeFromParent()
            foodBody.node?.physicsBody = nil
            
            spawnFood()
        default:
            print("something else touched the food")
        }
  }

}
