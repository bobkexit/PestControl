//
//  Bug.swift
//  PestControl
//
//  Created by Николай Маторин on 18.03.2020.
//  Copyright © 2020 Razeware LLC. All rights reserved.
//

import SpriteKit

class Bug: SKSpriteNode {
  init() {
    let texture = SKTexture(pixelImageNamed: "bug_ft1")
    super.init(texture: texture, color: .white, size: texture.size())
    physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
    physicsBody?.restitution = 0.5
    physicsBody?.allowsRotation = false
  }
  
  required init?(coder aDecoder: NSCoder) {
     fatalError("Use init()")
  }
}
