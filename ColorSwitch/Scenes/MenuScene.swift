import SpriteKit

class MenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        
        addLogo()
        addLabels()
    }
    
    func addLogo() {
        let logo = SKSpriteNode(imageNamed: "logo")
        logo.size = CGSize(width: frame.width / 4, height: frame.width / 4)
        logo.position = CGPoint(x: frame.midX, y: frame.midY + frame.size.height / 4)
        self.addChild(logo)
    }
    
    func addLabels() {
        let playLabel = SKLabelNode(text: "Tap to Play!")
        playLabel.fontName = "AvenirNext-Bold"
        playLabel.fontSize = 40.0
        playLabel.fontColor = .white
        playLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        animate(label: playLabel, type: .blink)
        self.addChild(playLabel)
        
        let highscoreLabel = SKLabelNode(text: "Highscore: \(UserDefaults.standard.integer(forKey: "Highscore"))")
        highscoreLabel.fontName = "AvenirNext-Bold"
        highscoreLabel.fontSize = 30.0
        highscoreLabel.fontColor = .white
        highscoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - highscoreLabel.frame.size.height * 4)
        self.addChild(highscoreLabel)
        
        let recentScoreLabel = SKLabelNode(text: "Last Score: \(UserDefaults.standard.integer(forKey: "Recentscore"))")
        recentScoreLabel.fontName = "AvenirNext-Bold"
        recentScoreLabel.fontSize = 20.0
        recentScoreLabel.fontColor = .white
        recentScoreLabel.position = CGPoint(x: frame.midX, y: highscoreLabel.position.y - recentScoreLabel.frame.size.height * 2)
        self.addChild(recentScoreLabel)
        
        setupSoundLabel()
    }
    
    func setupSoundLabel() {
        let soundOnOffLabel = TouchableNode(text: "Sound on")
        soundOnOffLabel.fontName = "AvenirNext-Bold"
        soundOnOffLabel.fontSize = 15.0
        soundOnOffLabel.fontColor = .white
        soundOnOffLabel.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        soundOnOffLabel.onTouch = {
            let isSoundOn = UserDefaults.standard.bool(forKey: "isSoundOn")
            if isSoundOn {
                UserDefaults.standard.set(false, forKey: "isSoundOn")
                soundOnOffLabel.text = "Sound Off"
            } else {
                UserDefaults.standard.set(true, forKey: "isSoundOn")
                soundOnOffLabel.text = "Sound On"
                self.playSound()
            }
            UserDefaults.standard.synchronize()
        }
        soundOnOffLabel.isUserInteractionEnabled = true
        
        let isSoundOn = UserDefaults.standard.bool(forKey: "isSoundOn")
        if isSoundOn {
            soundOnOffLabel.text = "Sound On"
        } else {
            soundOnOffLabel.text = "Sound Off"
        }
        
        self.addChild(soundOnOffLabel)
    }
    
    func playSound() {
        self.run(SKAction.playSoundFileNamed("bling", waitForCompletion: false))
    }
    
    func animate(label: SKLabelNode, type: AnimationType) {
        var action1: SKAction = SKAction()
        var action2: SKAction = SKAction()
        
        if type == .blink {
            action1 = SKAction.fadeOut(withDuration: 0.5)
            action2 = SKAction.fadeIn(withDuration: 0.5)
        } else if type == .bounce {
            action1 = SKAction.scale(to: 1.1, duration: 0.5)
            action2 = SKAction.scale(to: 1.0, duration: 0.5)
        }
    
        let sequence = SKAction.sequence([action1, action2])
        label.run(SKAction.repeatForever(sequence))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(size: view!.bounds.size)
        view?.presentScene(gameScene)
    }
}

enum AnimationType {
    case blink, bounce
}

class TouchableNode: SKLabelNode {
    var onTouch: (() -> Void)?
    var interactionEnabled: Bool = true {
        didSet {
            isUserInteractionEnabled = interactionEnabled
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTouch?()
    }
}































