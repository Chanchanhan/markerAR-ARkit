//
//  ViewController.swift
//  GlobalGoalsAR
//
//  Created by 钱权浩 on 2018/9/6.
//  Copyright © 2018年 qqh. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var magicSwitch: UISwitch!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    // Create video player
    
    
    let diffView : ZHPlayerView={
        let playView = ZHPlayerView(frame:  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        let url = Bundle.main.url(forResource: "Different Countries", withExtension: "mp4", subdirectory: "art.scnassets")
        playView.urlSrting = url?.absoluteString
        playView.isHidden = true
        playView.Pause()
        return playView
    }()
    
    let globalView : ZHPlayerView={
        let playView = ZHPlayerView(frame:  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        let url = Bundle.main.url(forResource: "global", withExtension: "mp4", subdirectory: "art.scnassets")
        playView.urlSrting = url?.absoluteString
        playView.isHidden = true
        playView.Pause()
        return playView
    }()
    let actionView : ZHPlayerView={
        let playView = ZHPlayerView(frame:  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        let url = Bundle.main.url(forResource: "Numbers In Action", withExtension: "mp4", subdirectory: "art.scnassets")
        playView.urlSrting = url?.absoluteString
        playView.isHidden = true
        playView.Pause()
        return playView
    }()
    let freedomView : ZHPlayerView={
        let playView = ZHPlayerView(frame:  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        let url = Bundle.main.url(forResource: "Freedom", withExtension: "mp4", subdirectory: "art.scnassets")
        playView.urlSrting = url?.absoluteString
        playView.isHidden = true
        playView.Pause()
        return playView
    }()
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        magicSwitch.setOn(false, animated: false)
        
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start the AR experience
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.pause()
    }
    
    // MARK: - Session management (Image detection setup)
    
    /// Prevents restarting the session while a restart is in progress.
    var isRestartAvailable = true
    
    @IBAction func switchOnMagic(_ sender: Any) {
        let configuration = ARImageTrackingConfiguration()
        
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            print("Could not load images")
            return
        }
        // Setup Configuration
        configuration.trackingImages = trackingImages
        configuration.maximumNumberOfTrackedImages = 4
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    
    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
    func resetTracking() {
        
        let configuration = ARImageTrackingConfiguration()
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - Image Tracking Results
    
    public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
  
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.diffView.isHidden = true
            self.globalView.isHidden = true
            self.actionView.isHidden = true
            self.freedomView.isHidden = true
        }
        
        // Show video overlaid on image
        if let imageAnchor = anchor as? ARImageAnchor {
            
            
            // Create a plane
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            if imageAnchor.referenceImage.name == "Different Countries" {
                // Set AVPlayer as the plane's texture and play
                plane.firstMaterial?.diffuse.contents = self.diffView.playerLayer.player
                self.diffView.Play()
                self.diffView.playerLayer.player?.volume = 0.4
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.diffView.isHidden = false
                }
            }else if imageAnchor.referenceImage.name ==  "global"{
                self.globalView.Play()
                plane.firstMaterial?.diffuse.contents = self.globalView.playerLayer.player
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.globalView.isHidden = false
                }
            }else if imageAnchor.referenceImage.name ==  "Freedom"{
                self.freedomView.Play()
                plane.firstMaterial?.diffuse.contents = self.freedomView.playerLayer.player
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.freedomView.isHidden = false
                }
            }else if imageAnchor.referenceImage.name ==  "n-Action"{
                self.actionView.Play()
                plane.firstMaterial?.diffuse.contents = self.actionView.playerLayer.player
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.actionView.isHidden = false
                }
            }
            let planeNode = SCNNode(geometry: plane)
            
            // Rotate the plane to match the anchor
            planeNode.eulerAngles.x = -.pi / 2
            
            // Add plane node to parent
            node.addChildNode(planeNode)
        }
        
        return node
    }
}
