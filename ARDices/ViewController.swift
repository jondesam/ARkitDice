//
//  ViewController.swift
//  ARDices
//
//  Created by MyMac on 2019-02-17.
//  Copyright © 2019 Apex. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var player : AVAudioPlayer?
    
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
      //  self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        
        //        let sphere = SCNSphere(radius: 0.2)
        //
        //        let material = SCNMaterial()
        //
        //        material.diffuse.contents = UIImage(named: "art.scnassets/8k_moon.jpg")
        //
        //        sphere.materials = [material]
        //
        //        let node = SCNNode()
        //
        //        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
        //
        //        node.geometry = sphere
        //
        //        sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
        // Create a new scene
        //        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        //
        //        if  let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
        //
        //        diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
        //
        //        sceneView.scene.rootNode.addChildNode(diceNode)
        //        }
        
        // Set the scene to the view
        //    sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

      
        configuration.planeDetection = .horizontal
        
        print("Session is supported = \(  ARConfiguration.isSupported)")
        print("World Tracking is supported = \( ARWorldTrackingConfiguration.isSupported)")
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let touchLocaion = touch.location(in: sceneView)
    
            let results = sceneView.hitTest(touchLocaion, types: .existingPlaneUsingExtent)
        
            //printing result
            //            if !results.isEmpty {
            //                print("touched the plane")
            //            } else {
            //                print("touched somewhere else")
            //            }
            
            //verifing result
            //            if let hitResult = results.first {
            //                print(hitResult)
            //            }
            
            if let hitResult = results.first {
                
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    
                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y ,// + diceNode.boundingSphere.radius // to move above
                        z: hitResult.worldTransform.columns.3.z
                    )
                    //putting dices on user's touch point
                    
                    diceArray.append(diceNode)
                    
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    roll(dice: diceNode )

                    playSound()
                }
            }
        }
    }
    
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice: SCNNode) {
       
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: 0,
                z: CGFloat(randomZ * 5),
                duration: 0.5) //half a second
        )
    }
    
    
    
    @IBAction func RollAgain(_ sender: UIBarButtonItem) {
        rollAll()
        playSound()
        
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
        playSound()
    }
    
    @IBAction func RemoveAllDices(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    
    
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("Delegate method called")
        
        if anchor is ARPlaneAnchor {
            
            print("plane detected")
            
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(
                x: planeAnchor.center.x,
                y: 0,
                z: planeAnchor.center.z)
            
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
        } else {
            return
        }
    }
    
    func playSound() {
        
        guard let url = Bundle.main.url(forResource: "vodka", withExtension: "wav") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }

//    let soundNames = ["soundName1", "soundName2", "soundName3"]
//
//    let randomSoundName = soundNames[Int(arc4random_uniform(UInt32(soundNames.count)))]
//
//    let randomSound = self.run(SKAction.playSoundFileNamed(randomSoundName, waitForCompletion: false))
    
}
