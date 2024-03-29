//
//  ViewController.swift
//  PokemonAR
//
//  Created by admin on 22/07/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import GameplayKit

class ViewController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSKViewDelegate
    //es metodo se llama cada vez que la escena genera un ancla.
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        let random = GKRandomSource.sharedRandom()
        let nextPokemon = random.nextInt(upperBound: 4) + 1
        
        let textura = SKTexture(imageNamed: "pokemon\(nextPokemon)")
        let pokemon = SKSpriteNode(texture: textura)
        return pokemon
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
