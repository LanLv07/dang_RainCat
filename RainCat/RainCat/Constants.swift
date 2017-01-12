//
//  Constants.swift
//  RainCat
//
//  Created by alan on 17/1/2.
//  Copyright © 2017年 Thirteen23. All rights reserved.
//

import Foundation

//为不同的物理实例的category设置不同的唯一值
let WorldCategory    : UInt32 = 0x1 << 1  //十六进制的1
let RainDropCategory : UInt32 = 0x1 << 2  //十六进制的2
let FloorCategory    : UInt32 = 0x1 << 3  //十六进制的4
let CatCategory      : UInt32 = 0x1 << 4
let FoodCategory     : UInt32 = 0x1 << 5

let ScoreKey = "RAINCAT_HIGHSCORE"
let MuteKey = "RAINCAT_MUTED"
