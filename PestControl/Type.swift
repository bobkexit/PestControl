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
