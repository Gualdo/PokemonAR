//
//  Scene.swift
//  PokemonAR
//
//  Created by De La Cruz, Eduardo on 31/12/2018.
//  Copyright © 2018 De La Cruz, Eduardo. All rights reserved.
//

import SpriteKit
import ARKit

class CommentedScene: SKScene {
    
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            /* Pos = (0,0,0), Rot = (0,0,0)
             [1,0,0,0] -> x
             [0,1,0,0] -> y
             [0,0,1,0] -> z
             [0,0,0,1] -> t
             */
            translation.columns.3.z = -0.2
            /* Pos = (0,0,-0.2), Rot = (0,0,0)
              0 1 2 3
             [1,0,0,  0 ] -> x
             [0,1,0,  0 ] -> y
             [0,0,1,-0.2] -> z
             [0,0,0,  1 ] -> t
             */
            let transform = simd_mul(currentFrame.camera.transform, translation)
            // Single Instruction Multiple Data - Multiply
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }
}
