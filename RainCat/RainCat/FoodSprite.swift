//
//  FoodSprite.swift
//  RainCat
//
//  Created by alan on 17/1/3.
//  Copyright © 2017年 Thirteen23. All rights reserved.
//

import Foundation
import SpriteKit

public class FoodSprite : SKSpriteNode {
    public static func newInstance() -> FoodSprite {
        let foodDish = FoodSprite(imageNamed: "food_dish")
        
        foodDish.physicsBody = SKPhysicsBody(rectangleOf: foodDish.size)
        foodDish.physicsBody?.categoryBitMask = FoodCategory
        foodDish.physicsBody?.contactTestBitMask = WorldCategory | RainDropCategory | CatCategory
        foodDish.zPosition = 5
        
        return foodDish
    }
}
