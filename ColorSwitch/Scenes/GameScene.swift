import SpriteKit

enum PlayColors {
    static let colors = [
        UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0),
        UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1.0),
        UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0),
        UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0),
        ]
}

enum SwitchState: Int {
    case red, yellow, green, blue
}

class GameScene: SKScene {
    
    var colorSwitch: SKSpriteNode!
    var switchState = SwitchState.red
    var currentColorIndex: Int?
    let increaseSpeedRate: CGFloat = 0.5
    let wheelRotationDuration = 0.1
    
    let scoreLabel = SKLabelNode(text: "0")
    var score: Int = 0 {
        didSet {
            increaseSpeed()
            playSound()
            scoreLabel.text = String(score)
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupPhysics()
        layoutScene()
    }
    
    func playSound() {
        if UserDefaults.standard.bool(forKey: "isSoundOn") {
            self.run(SKAction.playSoundFileNamed("bling", waitForCompletion: false))
        }
    }
    
    func increaseSpeed() {
        if score % 2 == 0 {
            let newSpeed = physicsWorld.gravity.dy - increaseSpeedRate
            physicsWorld.gravity = CGVector(dx: 0, dy: newSpeed)
        }
    }
    
    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -1.0)
        physicsWorld.contactDelegate = self
    }
    
    func layoutScene() {
        self.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        
        colorSwitch = SKSpriteNode(imageNamed: "ColorCircle")
        colorSwitch.size = CGSize(width: frame.size.width / 3, height: frame.size.width / 3)
        colorSwitch.position = CGPoint(x: frame.midX, y: frame.minY + colorSwitch.size.height)
        colorSwitch.zPosition = ZPositions.colorSwitch
        colorSwitch.physicsBody = SKPhysicsBody(circleOfRadius: colorSwitch.size.width / 2)
        colorSwitch.physicsBody?.categoryBitMask = PhysicsCategories.switchCategory
        colorSwitch.physicsBody?.isDynamic = false
        self.addChild(colorSwitch)
        
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 60.0
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        scoreLabel.zPosition = ZPositions.label
        self.addChild(scoreLabel)
        
        
        let leftTapView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width / 2.0, height: frame.size.height))
        leftTapView.backgroundColor = .clear
        
        let leftTapGesture = UITapGestureRecognizer(target: self, action: #selector(turnWheelCounterClockwise))
        leftTapView.addGestureRecognizer(leftTapGesture)
        
        let rightTapView = UIView(frame: CGRect(x: frame.size.width / 2.0, y: 0, width: frame.size.width / 2.0, height: frame.size.height))
        rightTapView.backgroundColor = .clear
        
        let rightTapGesture = UITapGestureRecognizer(target: self, action: #selector(turnWheelClockwise))
        rightTapView.addGestureRecognizer(rightTapGesture)

        view?.addSubview(leftTapView)
        view?.addSubview(rightTapView)
        
        spawnBall()
    }
    
    func spawnBall() {
        currentColorIndex = Int(arc4random_uniform(UInt32(4)))   // 0 - 3
        
        let ball = SKSpriteNode(texture: SKTexture(imageNamed: "ball"), color: PlayColors.colors[currentColorIndex!], size: CGSize(width: 30.0, height: 30.0))
        ball.colorBlendFactor = 1.0
        ball.size = CGSize(width: 30.0, height: 30.0)
        ball.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        ball.zPosition = ZPositions.ball
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.categoryBitMask = PhysicsCategories.ballCategory
        ball.physicsBody?.contactTestBitMask = PhysicsCategories.switchCategory
        ball.physicsBody?.collisionBitMask = PhysicsCategories.none
        
        self.addChild(ball)
    }
    
    @objc func turnWheelClockwise() {
        let stateNumber = Math.modulo((switchState.rawValue - 1), PlayColors.colors.count)
        if let newState = SwitchState(rawValue: stateNumber) {
            switchState = newState
        }
        
        colorSwitch.run(SKAction.rotate(byAngle: -.pi/2, duration: wheelRotationDuration))
    }
    
    @objc func turnWheelCounterClockwise() {
        if let newState = SwitchState(rawValue: (switchState.rawValue + 1) % PlayColors.colors.count) {
            switchState = newState
        }
        
        colorSwitch.run(SKAction.rotate(byAngle: .pi/2, duration: wheelRotationDuration))
    }
    
    func gameOver() {
        UserDefaults.standard.set(score, forKey: "Recentscore")
        if score > UserDefaults.standard.integer(forKey: "Highscore") {
            UserDefaults.standard.set(score, forKey: "Highscore")
        }
        
        let menuScene = MenuScene(size: view!.frame.size)
        view?.presentScene(menuScene)
    }
}

enum WheelDirection {
    case left, right
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.switchCategory {
            if let ball = contact.bodyA.node?.name == "Ball" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                if currentColorIndex == switchState.rawValue {
                    score += 1
                    ball.run(SKAction.fadeOut(withDuration: 0.25)) {
                        ball.removeFromParent()
                        self.spawnBall()
                    }
                } else {
                    gameOver()
                }
            }
        }
    }
}


struct Math {
    static func modulo(_ a: Int, _ n: Int) -> Int {
        precondition(n > 0, "modulus must be positive")
        let r = a % n
        return r >= 0 ? r : r + n
    }
}
