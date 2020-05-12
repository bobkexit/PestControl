//
//  Type.swift
//  PestControl
//
//  Created by Николай Маторин on 06.03.2020.
//  Copyright © 2020 Razeware LLC. All rights reserved.
//

import SpriteKit

enum Direction: Int {
  case forward = 0, backward, left, right
}

extension SKTexture {
  convenience init(pixelImageNamed: String) {
    self.init(imageNamed: pixelImageNamed)
    self.filteringMode = .nearest
  }
}

typealias TileCoordinates = (column: Int, row: Int)

struct PhysicsCategory {
  static let none:      UInt32 = 0
  static let all:       UInt32 = 0xFFFFFFFF
  static let edge:      UInt32 = 0b1
  static let player:    UInt32 = 0b10
  static let bug:       UInt32 = 0b100
  static let firebug:   UInt32 = 0b1000
  static let breakable: UInt32 = 0b10000
}

enum GameState: Int {
  case initial = 0, start, play, win, lose, reload, pause
}
