//
//  Firebug.swift
//  PestControl
//
//  Created by Николай Маторин on 21.03.2020.
//  Copyright © 2020 Razeware LLC. All rights reserved.
//

import SpriteKit

class Firebug: Bug {
  
  override init() {
    super.init()
    name = "Firebug"
    color = .red
    colorBlendFactor = 0.8
    physicsBody?.categoryBitMask = PhysicsCategory.firebug
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
}
