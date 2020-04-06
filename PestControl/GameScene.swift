/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit

class GameScene: SKScene {
  var background: SKTileMapNode!
  var obstaclesTileMap: SKTileMapNode?
  var bugsprayTileMap: SKTileMapNode?
  var player = Player()
  var bugsNode = SKNode()
  var firebugCount: Int = 0
  var hud = HUD()
  var timeLimit: Int = 10
  var elapsedTime: Int = 0
  var startTime: Int?
  var gameState: GameState = .initial {
    didSet {
      hud.updateGameState(from: oldValue, to: gameState)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    background = childNode(withName: "background") as? SKTileMapNode
    obstaclesTileMap = childNode(withName: "obstacles") as? SKTileMapNode
  }
  
  override func didMove(to view: SKView) {
    addChild(player)
    setupCamera()
    setupWorldPhysics()
    createBugs()
    setupObstaclePhysics()
    
    if firebugCount > 0 {
      creatBugspay(quantity: firebugCount + 10)
    }
    
    setupHUD()
  }
  
  override func update(_ currentTime: TimeInterval) {
    if !player.hasBugspray {
      updateBugspray()
    }
    advanceBreakableTile(locatedAt: player.position)
    updateHUD(currentTime: currentTime)
    checkEndGame()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    player.move(target: touch.location(in: self))
  }
  
  func setupCamera() {
    guard let camera = camera, let view = view else { return }
    let zeroDistance = SKRange(constantValue: 0)
    let playerConstraint = SKConstraint.distance(zeroDistance, to: player)
    
    let xInset = min(view.bounds.width/2 * camera.xScale, background.frame.width/2)
    let yInset = min(view.bounds.height/2 * camera.yScale, background.frame.height/2)
    
    let constraintRect = background.frame.insetBy(dx: xInset, dy: yInset)
    
    let xRange = SKRange(lowerLimit: constraintRect.minX, upperLimit: constraintRect.maxX)
    let yRange = SKRange(lowerLimit: constraintRect.minY, upperLimit: constraintRect.maxY)
    
    let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
    edgeConstraint.referenceNode = background
    
    camera.constraints = [playerConstraint, edgeConstraint]
  }
  
  func setupWorldPhysics() {
    background.physicsBody = SKPhysicsBody(edgeLoopFrom: background.frame)
    background.physicsBody?.categoryBitMask = PhysicsCategory.edge
    physicsWorld.contactDelegate = self
  }
  
  func tile(in tileMap: SKTileMapNode, at coordinates: TileCoordinates) -> SKTileDefinition? {
    return tileMap.tileDefinition(atColumn: coordinates.column, row: coordinates.row)
  }
  
  func createBugs() {
    guard let bugsMap = childNode(withName: "bugs") as? SKTileMapNode else {
      return
    }
    
    for row in 0..<bugsMap.numberOfRows {
      for column in 0..<bugsMap.numberOfColumns {
        guard let title = tile(in: bugsMap, at: (column, row)) else {
          continue
        }
        let bug: Bug
        if title.userData?.object(forKey: "firebug") != nil {
          bug = Firebug()
          firebugCount += 1
        } else {
          bug = Bug()
        }
        bug.position = bugsMap.centerOfTile(atColumn: column, row: row)
        bugsNode.addChild(bug)
        bug.move()
      }
    }
    bugsNode.name = "Bugs"
    addChild(bugsNode)
    bugsMap.removeFromParent()
  }
  
  func remove(bug: Bug) {
    bug.removeFromParent()
    background.addChild(bug)
    bug.die()
  }
  
  func setupObstaclePhysics() {
    guard let obstaclesTileMap = obstaclesTileMap else { return }
    for row in 0..<obstaclesTileMap.numberOfRows {
      for column in 0..<obstaclesTileMap.numberOfColumns {
        guard let tile = tile(in: obstaclesTileMap, at: (column, row)) else {
          continue
        }
        guard tile.userData?.object(forKey: "obstacle") != nil else {
          continue
        }
        let node = SKNode()
        node.physicsBody = SKPhysicsBody(rectangleOf: tile.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.friction = 0
        node.physicsBody?.categoryBitMask = PhysicsCategory.breakable
        node.position = obstaclesTileMap.centerOfTile(atColumn: column, row: row)
        obstaclesTileMap.addChild(node)
      }
    }
  }
  
  func creatBugspay(quantity: Int) {
    let texture = SKTexture(pixelImageNamed: "bugspray")
    let tile = SKTileDefinition(texture: texture)
    let tileRule = SKTileGroupRule(adjacency: .adjacencyAll, tileDefinitions: [tile])
    let tileGroup = SKTileGroup(rules: [tileRule])
    let tileSet = SKTileSet(tileGroups: [tileGroup])
    
    let columns = background.numberOfColumns
    let rows = background.numberOfRows
    bugsprayTileMap = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tile.size)
    
    for _ in 1...quantity {
      let column = Int.random(min: 0, max: columns-1)
      let row = Int.random(min: 0, max: rows-1)
      bugsprayTileMap?.setTileGroup(tileGroup, forColumn: column, row: row)
    }
    bugsprayTileMap?.name = "Bugspray"
    addChild(bugsprayTileMap!)
  }
  
  func tileCoordinates(in tileMap: SKTileMapNode, at position: CGPoint) -> TileCoordinates {
    let column = tileMap.tileColumnIndex(fromPosition: position)
    let row = tileMap.tileRowIndex(fromPosition: position)
    return (column, row)
  }
  
  func updateBugspray() {
    guard let bugsprayTileMap = bugsprayTileMap else { return }
    let (column, row) = tileCoordinates(in: bugsprayTileMap, at: player.position)
    if tile(in: bugsprayTileMap, at: (column, row)) != nil {
      bugsprayTileMap.setTileGroup(nil, forColumn: column, row: row)
      player.hasBugspray = true
    }
  }
  
  func tileGroupForName(tileSet: SKTileSet, name: String) -> SKTileGroup? {
    let tileGroup = tileSet.tileGroups.filter { $0.name == name }.first
    return tileGroup
  }
  
  func advanceBreakableTile(locatedAt nodePosition: CGPoint) {
    guard let obstaclesTileMap = obstaclesTileMap else { return }
    let (column, row) = tileCoordinates(in: obstaclesTileMap, at: nodePosition)
    let obstacle = tile(in: obstaclesTileMap, at: (column, row))
    guard let nextTileGroupName = obstacle?.userData?.object(forKey: "breakable") as? String else {
      return
    }
    if let nextTileGroupName = tileGroupForName(tileSet: obstaclesTileMap.tileSet,
                                                name: nextTileGroupName) {
      obstaclesTileMap.setTileGroup(nextTileGroupName, forColumn: column, row: row)
    }
  }
  
  func setupHUD() {
    camera?.addChild(hud)
    hud.addTimer(time: timeLimit)
  }
  
  func updateHUD(currentTime: TimeInterval) {
    if let startTime = startTime {
      elapsedTime = Int(currentTime) - startTime
    } else {
      startTime = Int(currentTime) - elapsedTime
    }
    hud.updateTimer(time: timeLimit - elapsedTime)
  }
  
  func checkEndGame() {
    if bugsNode.children.count == 0 {
      player.physicsBody?.linearDamping = 1
      gameState = .win
    } else if timeLimit - elapsedTime <= 0 {
      player.physicsBody?.linearDamping = 1
      gameState = .lose
    }
  }
}

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    let other = contact.bodyA.categoryBitMask == PhysicsCategory.player
      ? contact.bodyB : contact.bodyA
    switch other.categoryBitMask {
    case PhysicsCategory.bug:
      if let bug = other.node as? Bug {
        remove(bug: bug)
      }
    case PhysicsCategory.firebug:
      if player.hasBugspray, let firebug = other.node as? Firebug {
        remove(bug: firebug)
        player.hasBugspray = false
      }
    case PhysicsCategory.breakable:
      if let obstacleNode = other.node {
        advanceBreakableTile(locatedAt: obstacleNode.position)
        obstacleNode.removeFromParent()
      }
    default:
      break
    }
    
    if let physicsBody = player.physicsBody, physicsBody.velocity.length() > 0 {
      player.checkDiraction()
    }
  }
}
