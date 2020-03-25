//
//  Bug.swift
//  PestControl
//
//  Created by Николай Маторин on 18.03.2020.
//  Copyright © 2020 Razeware LLC. All rights reserved.
//

import SpriteKit

enum BugSettings {
  static let bugDistance: CGFloat = 16
}

class Bug: SKSpriteNode {
  
  var animations: [SKAction] = []
  
  init() {
    let texture = SKTexture(pixelImageNamed: "bug_ft1")
    super.init(texture: texture, color: .white, size: texture.size())
    physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
    physicsBody?.restitution = 0.5
    physicsBody?.allowsRotation = false
    physicsBody?.categoryBitMask = PhysicsCategory.bug
    createAnimation(character: "bug")
  }
  
  required init?(coder aDecoder: NSCoder) {
     fatalError("Use init()")
  }
  
  func move() {
    let randomX = CGFloat(Int.random(min: -1, max: 1))
    let randomY = CGFloat(Int.random(min: -1, max: 1))
    
    let vector = CGVector(dx: randomX * BugSettings.bugDistance,
                          dy: randomY * BugSettings.bugDistance)
    
    let mobeBy = SKAction.move(by: vector, duration: 1)
    let moveAgain = SKAction.run(move)
    
    let diraction = animationDirection(for: vector)
    
    if diraction == .left {
      xScale = abs(xScale)
    } else if diraction == .right {
      xScale = -abs(xScale)
    }
    
    run(animations[diraction.rawValue], withKey: "animation")
    run(.sequence([mobeBy, moveAgain]))
  }
  
  func die() {
    removeAllActions()
    texture = SKTexture(pixelImageNamed: "bug_lt1")
    yScale = -1
    physicsBody = nil
    run(.sequence([.fadeOut(withDuration: 3), .removeFromParent()]))
  }
}

extension Bug: Animatable {}
