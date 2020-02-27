//
//  ViewController.swift
//  Entrega AR
//
//  Created by Matheus Oliveira on 21/02/20.
//  Copyright © 2020 Matheus Oliveira. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    // Pokemon information
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var height: UILabel!
    @IBOutlet weak var type: UILabel!
    
    // Labels
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        let scene = SCNScene(named: "art.scnassets/StartingScene.scn")!
        sceneView.scene = scene
        hideLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let imageTrackingConfiguration = ARImageTrackingConfiguration()
        
        guard let trackedImage = ARReferenceImage.referenceImages(inGroupNamed: "Cards",
                                                                  bundle: Bundle.main) else {
            print("Image not found")
            return
        }
        
        imageTrackingConfiguration.trackingImages = trackedImage
        
        // As our pokédex will only show one
        // pokemon information at time, lets keep the
        // maximumNumberOfTrackedImages equals to 1
        imageTrackingConfiguration.maximumNumberOfTrackedImages = 1
        
        sceneView.session.run(imageTrackingConfiguration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playStartSound()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // MARK: - Labels Manager
    
    fileprivate func hideLabels() {
        self.name.isHidden = true
        self.number.isHidden = true
        self.weightLabel.isHidden = true
        self.weight.isHidden = true
        self.heightLabel.isHidden = true
        self.height.isHidden = true
        self.typeLabel.isHidden = true
        self.type.isHidden = true
    }
    
    fileprivate func showLabels() {
        self.name.isHidden = false
        self.number.isHidden = false
        self.weightLabel.isHidden = false
        self.weight.isHidden = false
        self.heightLabel.isHidden = false
        self.height.isHidden = false
        self.typeLabel.isHidden = false
        self.type.isHidden = false
    }
    
    // MARK: - Sounds Manager
    
    func playStartSound() {
        guard let url = Bundle.main.url(forResource: "pokedexStart", withExtension: "mov") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playPokemonSound(pokemonName: String) {
        guard let url = Bundle.main.url(forResource: pokemonName, withExtension: "mov") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}

    // MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            
            // Building a plane over the tracked image
            let pokemonCard = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                                   height: imageAnchor.referenceImage.physicalSize.height)
            
            // Adding pokédex background to this plane
            if let  image = UIImage(named: "pokedex-background") {
                pokemonCard.firstMaterial?.diffuse.contents = image
            }
            
            let pokemonCardNode = SCNNode(geometry: pokemonCard)
            
            // Matching plane rotation with the pokemon
            pokemonCardNode.eulerAngles.x = -.pi / 2
            
            let referenceImage = imageAnchor.referenceImage
            let imageName = referenceImage.name ?? ""
            
            DispatchQueue.main.async {
                let pokemon:Pokemon = self.buildPokemon(name: imageName)
                self.buildPokedexInformation(pokemon: pokemon)
                self.build3DPokemon(imageName: imageName, pokemonCardNode: pokemonCardNode)
                self.showLabels()
                self.playPokemonSound(pokemonName: imageName)
            }
            
            node.addChildNode(pokemonCardNode)
        }
    }
        
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        if let imageAnchor = anchor as? ARImageAnchor {

            if (!imageAnchor.isTracked) {
                // Pokemon disappeared from card
                DispatchQueue.main.async {
                    self.hideLabels()
                    self.sceneView.session.remove(anchor: anchor)
                }
            }
            
        }
    }
    
    // MARK: - Pokemon builders
    
    func buildPokedexInformation(pokemon: Pokemon) {

        self.name.text = pokemon.name
        self.number.text = pokemon.number
        self.weight.text = pokemon.weight
        self.height.text = pokemon.heigth
        self.type.text = pokemon.type
    }
    
    func buildPokemon(name: String) -> Pokemon {
        // Returns a pokemon object according to
        // image traked
        
        switch name {
        case "Eevee":
            return Pokemon(name: "Eevee", number: "#133", weight: "6.5 kg",
                           height: "0.3 m", type: "Normal")
        case "Lapras":
            return Pokemon(name: "Lapras", number: "#131", weight: "220.0 kg",
                           height: "2.5 m", type: "Transporte")
        default:
            return Pokemon(name: "Eevee", number: "#133", weight: "6.5 kg",
                           height: "0.3 m", type: "Normal")
        }
    }
    
    func build3DPokemon(imageName: String, pokemonCardNode: SCNNode) {
        // Adds a pokemon node according to
        // image tracked
        
        let pokemonScene = SCNScene(named: "art.scnassets/\(imageName).scn")!
        let pokemonNode = pokemonScene.rootNode.childNodes.first!
        
        // Positioning pokemon with the same position of the
        // card (0, 0, 0), but changing Z so it can be at the front
        pokemonNode.position = SCNVector3(0, 0, 0.15)
        pokemonCardNode.addChildNode(pokemonNode)
        rotatePokemon(pokemonNode)
    }
    
    // MARK: - Pokemon rotation
    
    fileprivate func rotatePokemon(_ pokemonNode: SCNNode) {
        // Rotates pokemon 3D model
        
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 15)
        let repAction = SCNAction.repeatForever(action)
        pokemonNode.runAction(repAction, forKey: "pokemonRotation")
    }
}
