//
//  Scene.swift
//  PokemonAR
//
//  Created by admin on 22/07/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit //para generar numero aleatorios

class Scene: SKScene {
    
    let remainingLabel = SKLabelNode()
    var timer : Timer?
    var targetCreated = 0 { //cuantas hay creadas
        didSet{
            self.remainingLabel.text = "cazados: \(targetCount) --- creados: \(targetCreated)"
        }
    }
    var targetCount =  0 { //cuenta cuantas hay visibles.
        didSet{
            self.remainingLabel.text = "cazados: \(targetCount) --- creados: \(targetCreated)"
        }
    }
    
    let startTime = Date()
    
    let deathSound = SKAction.playSoundFileNamed("QuickDeath", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
    
        remainingLabel.fontSize = 30
        remainingLabel.fontName = "Market felt"
        remainingLabel.color = .white
        remainingLabel.position = CGPoint(x: view.frame.minY, y: view.frame.midX - 50)
        print(view.frame.midX)
        addChild(remainingLabel)
        targetCount = 0
        
        //crear enemigos cada 3 segundo
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                                    self.createTarget()
                                    })
    }
    
    func createTarget(){
        //parar el timer si ya hay 25 enemigos creados.
        if targetCreated >= 9{
            timer?.invalidate()
            //destruir el timer.
            timer = nil
        }

        
        //crear un nuevo enemigo
        targetCreated += 1
        
        //crear generador de numero aleatorio.
        let random = GKRandomSource.sharedRandom()
        
        //calcular posicion en z
        var posicionZ: Float = -0.5
        let numeroRandom = -1 * (Float(random.nextInt(upperBound: 2)) + random.nextUniform())
        if numeroRandom < -0.6 {
            posicionZ = numeroRandom
            }
        else{
            posicionZ += numeroRandom
        }
        guard let sceneView = self.view as? ARSKView else{ return }

        //crear una matriz de rotacion aleatoria en x.
        let rotateX = simd_float4x4(SCNMatrix4MakeRotation(2.0 * Float.pi * random.nextUniform(), 1, 0, 0))
        //crear una matriz de rotacion aleatoria en y.
        let rotateY = simd_float4x4(SCNMatrix4MakeRotation(2.0 * Float.pi * random.nextUniform() , 0, 1, 0))
        //combinar las dos rotaciones con un producto de matrices.
        let rotation = simd_mul(rotateX, rotateY)
        //crear una translacion de 1.5 metros en la direccion de la pantalla, eje Z.
        var translation = matrix_identity_float4x4

        translation.columns.3.z = posicionZ
        //combinar la rotacion del paso 4 con la traslacion.
        let finalTransform = simd_mul(rotation, translation) //primero las transformaciones (rotate) y despues el movimiento (translation)
        //crear un punto de ancla en el punto final determinado en el paso 6.
        let anchor = ARAnchor(transform: finalTransform)
        //añadir esa ancla a la escena.
        sceneView.session.add(anchor: anchor)
        
        /*
         ejemplo de las matrices.
         creacion de la matriz:
         var translation = matrix_identity_float4x4
         // Pos = (0,0,0), Rot = (0,0,0)
         // 0 1 2 3
         //[1,0,0,0] -> x
         //[0,1,0,0] -> y
         //[0,0,1,0] -> z
         //[0,0,0,1] -> t
         
         translation.columns.3.z = -0.2
         // Pos = (0,0,-0.2), Rot = (0,0,0)
         // 0 1 2   3
         //[1,0,0,  0] -> x
         //[0,1,0,  0] -> y
         //[0,0,1, -0.2] -> z
         //[0,0,0,  1] -> t
         
         */
        
    }
    
    func gameOver(){
        //ocultar remainingLabel
        remainingLabel.removeFromParent()
        //crear nuevo sprite con la imagen de gameover.
        let gameOverSprite = SKSpriteNode(imageNamed: "gameover")
        addChild(gameOverSprite)
        //calcular tiempo de juego.
        let timeTaken = Date().timeIntervalSince(startTime)
        //Mostrar tiempo en pantalla en una label nueva.
        let timeTakenLabel = SKLabelNode(text: """
            GAME OVER!!! 
            Has tardado: \(Int(timeTaken)) segundos
        """)
        timeTakenLabel.fontName = "Market felt"
        timeTakenLabel.fontSize = 50
        timeTakenLabel.color = .white
        timeTakenLabel.position = CGPoint(x: 0, y: 0)
        addChild(timeTakenLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        //localizar el primer toque del conjunto de toques.
        //mirar si el toque cae dentro de nuestra vista de AR.
        guard let touche = touches.first else {return}
        let location = touche.location(in: self)
        //nodes devuelve todos los nodos de los que se muestran en pantalla.
        //y en hit guarda los que nodos que han sido tocados por ese toque de usuario.
        let hit = nodes(at: location)
        //cogeremos el primer sprite del array que nos devuelve el método anterior (si lo hay) y animaremos ese pokemon hasta hacerlo desaparecer.
        if let sprite = hit.first{
            //print("posicion z: \(sprite.zPosition)")
            //print("posicion x: \(sprite.position.x)")
            //print("posicion y: \(sprite.position.y)")
            let scaleOut = SKAction.scale(to: 2, duration: 0.5)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let groupAction = SKAction.group([scaleOut,fadeOut,deathSound])
            let sequenceAction = SKAction.sequence([groupAction,SKAction.removeFromParent()])
            sprite.run(sequenceAction)
        }
        //actualizaremos que hay un pokemon menos con la variable target count.
        targetCount += 1
        
        if targetCreated >= 10 && targetCount == 10{
            gameOver()
        }
    }
}
