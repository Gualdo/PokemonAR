//
//  Scene.swift
//  PokemonAR
//
//  Created by De La Cruz, Eduardo on 02/01/2019.
//  Copyright © 2019 De La Cruz, Eduardo. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit

class Scene: SKScene {
    
    fileprivate let remainingLabel = SKLabelNode()
    fileprivate var timer: Timer?
    fileprivate var targetsCreated = 0
    fileprivate var targetCount = 0 {
        didSet {
            self.remainingLabel.text = "Faltan: \(targetCount)"
        }
    }
    let startTime = Date()
    let deathSound = SKAction.playSoundFileNamed("QuickDeath", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        // Configuracion del HUD (Heads Up Display)
        remainingLabel.fontSize = 30
        remainingLabel.fontName = "Avenir Next"
        remainingLabel.color = .white
        remainingLabel.position = CGPoint(x: 0, y: view.frame.midY - 50)
        addChild(remainingLabel)
        targetCount = 0
        
        // Creacion de enemigos cada 3 segundos
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { (timer) in
            self.createTarget()
        })
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Localizar el primer toque del conjunto de toques
        // Mirar si el toque cae dentro de nuestra vista de AR
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        print("El toque ha sido en: \(location.x) , \(location.y)")
        
        // Buscaremos todos los nodos que han sido tocados por ese toque de usuario
        
        let hit = nodes(at: location)
        
        // Cojeremos el primer sprite del array que nos devuelve el método anterior (si lo hay) y animaremos ese pokemon hasta hacerlo desaparecer
        
        if let sprite = hit.first {
            let scaleOut = SKAction.scale(to: 2, duration: 0.4)
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            let remove = SKAction.removeFromParent()
            let groupedAction = SKAction.group([scaleOut, fadeOut, deathSound])
            let sequenceAction = SKAction.sequence([groupedAction, remove])
            sprite.run(sequenceAction)
        }
        
        // Actualizaremos que hay un pokemon menos con la variable targetCount
        
        targetCount -= 1
        
        if targetsCreated == 25 && targetCount == 0 {
            gameOver()
        }
    }
    
    fileprivate func createTarget() {
        if targetsCreated == 25 {
            timer?.invalidate()
            timer = nil
            return
        }
        
        targetsCreated += 1
        targetCount += 1
        
        guard let sceneView = self.view as? ARSKView else { return }
        
        // 1.- Crear un generador de números aleatorios
        
        let random = GKRandomSource.sharedRandom()
        
        // 2.- Crear una matriz de rotación aleatoria en x
        
        let rotateX = float4x4.init(SCNMatrix4MakeRotation((2.0 * Float.pi * random.nextUniform()), 1, 0, 0))
        
        // 3.- Crear una matriz de rotación aleatoria en y
        
        let rotateY = float4x4.init(SCNMatrix4MakeRotation((2.0 * Float.pi * random.nextUniform()), 0, 1, 0))
        
        // 4.- Combinar las dos rotaciones con un producto de matrices
        
        let rotation = simd_mul(rotateX, rotateY)
        
        // 5.- Crear una translación de 1.5 metros en la dirección de la pantalla
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.5 // En direccion dentro de la pantalla
        
        // 6.- Combinar la rotación del paso 4 con la traslación del paso 5
        
        let finalTransform = simd_mul(rotation, translation)
        
        // 7.- Crear un punto de ancla en el punto final determinado en el paso 6
        
        let anchor = ARAnchor(transform: finalTransform)
        
        // 8.- Añadir esa ancla a la escena
        
        sceneView.session.add(anchor: anchor)
    }
    
    fileprivate func gameOver() {
        // Ocultar la remainingLabel
        
        remainingLabel.removeFromParent()
        
        // Crear una nueva imagen con la foto de game over
        
        let gameOver = SKSpriteNode(imageNamed: "gameover")
        addChild(gameOver)
        
        // Calcular cuanto tiempo le ha llevado al usuario cazar a todos los pokemon
        
        let timeTaken = Date().timeIntervalSince(startTime)
        
        // Mostrar ese tiempo que le ha llevado en pantalla en una etiqueta nueva
        
        let timeTakenLabel = SKLabelNode(text: "Te ha llevado: \(Int(timeTaken))")
        timeTakenLabel.fontSize = 40
        timeTakenLabel.color = .white
        guard let center = view?.frame.midY else {
            timeTakenLabel.position = CGPoint(x: 0, y: 0)
            addChild(timeTakenLabel)
            return
        }
        timeTakenLabel.position = CGPoint(x: 0, y: center + 50)
        addChild(timeTakenLabel)
    }
}
