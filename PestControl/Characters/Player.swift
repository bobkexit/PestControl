//
//  Player.swift
//  PestControl
//
//  Created by Николай Маторин on 05.03.2020.
//  Copyright © 2020 Razeware LLC. All rights reserved.
//

import SpriteKit

enum PlayerSettings {
  static let playerSpeed: CGFloat = 280.0
}

class Player: SKSpriteNode {
  
  var animations: [SKAction] = []
  
  init() {
    let texture = SKTexture(pixelImageNamed: "player_ft1")
    super.init(texture: texture, color: .white, size: texture.size())
    name = "Player"
    zPosition = 50
    physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
    physicsBody?.restitution = 1.0
    physicsBody?.linearDamping = 0.5
    physicsBody?.friction = 0
    physicsBody?.allowsRotation = false
    physicsBody?.categoryBitMask = PhysicsCategory.player
    physicsBody?.contactTestBitMask = PhysicsCategory.all
    createAnimation(character: "player")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Use init()")
  }
  
  func move(target: CGPoint) {
    guard let physicsBody = physicsBody else { return }
    
    let newVelocity = (target - position).normalized() * PlayerSettings.playerSpeed
    physicsBody.velocity = CGVector(point: newVelocity)
    
    checkDiraction()
  }
  
  func checkDiraction() {
    guard let physicsBody = physicsBody else { return }
    let diraction = animationDirection(for: physicsBody.velocity)
    
    if diraction == .left {
      xScale = abs(xScale)
    }
    
    if diraction == .right {
      xScale = -abs(xScale)
    }
    
    run(animations[diraction.rawValue], withKey: "animation")
  }
}

extension Player: Animatable {}
