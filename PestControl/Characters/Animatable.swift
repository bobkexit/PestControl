//
//  Animatable.swift
//  PestControl
//
//  Created by Николай Маторин on 06.03.2020.
//  Copyright © 2020 Razeware LLC. All rights reserved.
//

import SpriteKit

protocol Animatable: class {
  var animations: [SKAction] { get set }
}

extension Animatable {
  func animationDirection(for directionVector: CGVector) -> Direction {
    let direction: Direction
    
    if abs(directionVector.dy) > abs(directionVector.dx) {
      direction = directionVector.dy < 0 ? .forward : .backward
    } else {
      direction = directionVector.dx < 0 ? .left : .right
    }
    
    return direction
  }
  
  func createAnimation(character: String) {
    let actionForward: SKAction = .animate(with: [
      SKTexture(pixelImageNamed: "\(character)_ft1"),
      SKTexture(pixelImageNamed: "\(character)_ft2")
    ], timePerFrame: 0.2)
    animations.append(.repeatForever(actionForward))
    
    let actionBackward: SKAction = .animate(with: [
      SKTexture(pixelImageNamed: "\(character)_bk1"),
      SKTexture(pixelImageNamed: "\(character)_bk2")
    ], timePerFrame: 0.2)
    animations.append(.repeatForever(actionBackward))
    
    let actionLeft: SKAction = .animate(with: [
         SKTexture(pixelImageNamed: "\(character)_lt1"),
         SKTexture(pixelImageNamed: "\(character)_lt2")
       ], timePerFrame: 0.2)
    animations.append(.repeatForever(actionLeft))
    
    animations.append(.repeatForever(actionLeft))
  }
}
