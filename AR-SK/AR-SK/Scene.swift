//
//  Scene.swift
//  AR-SK
//
//  Created by 刘文 on 2017/9/13.
//  Copyright © 2017年 刘文. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    
    var playing = false
    
    var sorce = 0
    
    var BombTimer: Timer?
    
    
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !playing {
            playing = true
            for label in children {
                label.removeFromParent()
            }
            addBomb()
        } else {
            guard let location = touches.first?.location(in: self) else {
                return
            }
            
            for node in children {
                if node.contains(location) && node.name == "Bomb" {
                    BombTimer?.invalidate()
                    sorce += 1
                    
                    let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                    node.run(fadeOut, completion: {
                        node.removeFromParent()
                        self.addBomb()
                    })
                }
            }
        }
    }
    
    func addBomb() {
        guard let secneView = self.view as? ARSKView else {
            return
        }
        if let currentFrame = secneView.session.currentFrame {
            let xOffset = Float(arc4random_uniform(UInt32(30))) / 10 - 1.5
            let zOffset = Float(arc4random_uniform(UInt32(20))) / 10 + 0.5
            
            var tranform = matrix_identity_float4x4
            tranform.columns.3.x = currentFrame.camera.transform.columns.3.x - xOffset
            tranform.columns.3.z = currentFrame.camera.transform.columns.3.z - zOffset
            tranform.columns.3.y = currentFrame.camera.transform.columns.3.y
            
            let anchor = ARAnchor(transform: tranform)
            secneView.session.add(anchor: anchor)
        }
        
        BombTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(explode), userInfo: nil, repeats: false)
    }
    
    @objc func explode() {
        BombTimer?.invalidate()
        
        if UserDefaults.standard.integer(forKey: "HighestScore") < sorce {
            UserDefaults.standard.set(sorce, forKey: "HighestScore")
        }
        
        for node in children {
            if let node = node as? SKLabelNode, node.name == "Bomb" {
                node.text = "💥"
                node.name = "Menu"
                
                let scaleExplode = SKAction.scale(to: 50, duration: 1.0)
                node.run(scaleExplode, completion: {
                    self.displayMenu()
                    self.playing = false
                    self.sorce = 0
                })
            }
        }
    }
    
    func displayMenu() {
        let logoLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        logoLabel.fontSize = 50.0
        
        logoLabel.text = "Game Over!"
        logoLabel.verticalAlignmentMode = .center
        logoLabel.horizontalAlignmentMode = .center
        
        logoLabel.position = CGPoint(x: frame.midX, y: frame.midY + logoLabel.frame.size.height * 3)
        
        logoLabel.name = "Menu"
        self.addChild(logoLabel)
        
        let infoLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        infoLabel.fontSize = 50.0
        
        infoLabel.text = "你被炸飛了"
        infoLabel.verticalAlignmentMode = .center
        infoLabel.horizontalAlignmentMode = .center
        
        infoLabel.position = CGPoint(x: frame.midX, y: frame.midY + logoLabel.frame.size.height * 1.5)
        
        infoLabel.name = "Menu"
        self.addChild(infoLabel)
        
        let currentScore = SKLabelNode(fontNamed: "AvenirNext-Bold")
        currentScore.fontSize = 50.0
        
        currentScore.text = "分数：\(sorce)"
        currentScore.verticalAlignmentMode = .center
        currentScore.horizontalAlignmentMode = .center
        
        currentScore.position = CGPoint(x: frame.midX, y: frame.midY)
        
        currentScore.name = "Menu1" //??
        self.addChild(currentScore)
        
        let higthtScore = SKLabelNode(fontNamed: "AvenirNext-Bold")
        higthtScore.fontSize = 50.0
        
        higthtScore.text = "最高分：\(UserDefaults.standard.integer(forKey: "HighestScore"))"
        higthtScore.verticalAlignmentMode = .center
        higthtScore.horizontalAlignmentMode = .center
        
        higthtScore.position = CGPoint(x: frame.midX, y: frame.midY - logoLabel.frame.size.height * 1.5)
        
        higthtScore.name = "Menu1" //??
        self.addChild(higthtScore)
    }
}
