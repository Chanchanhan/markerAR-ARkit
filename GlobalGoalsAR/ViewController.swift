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
    var timer:Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        magicSwitch.setOn(false, animated: false)
        
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        timer = Timer.scheduledTimer(timeInterval: 0.5,
                                     target:self,selector:#selector(StopPlay),
                                                       userInfo:nil,repeats:true)

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
        timer.invalidate()
        session.pause()
    }
    @objc func StopPlay()
    {
        
        let currentFrame = session.currentFrame!
        let width = self.view.frame.width
        let height = self.view.frame.height
        var state1 = false
        var state2 = false
        var state3 = false
        var state4 = false
        
        for anchor in currentFrame.anchors{
            if let imageAnchor = anchor as? ARImageAnchor{
                var state = false
                let X = SCNVector3(imageAnchor.transform.columns.3.x, imageAnchor.transform.columns.3.y, imageAnchor.transform.columns.3.z)
                let projectedPoint = sceneView.projectPoint(X)
                let x = CGFloat(projectedPoint.x)
                let y = CGFloat(projectedPoint.y)

                if(x > 0 && x < width && y > 0 && y < height) {
                    state = true
                }
                if imageAnchor.referenceImage.name == "Different Countries" {
                    state1 = state
                }else if imageAnchor.referenceImage.name ==  "global"{
                    state2 = state
                }else if imageAnchor.referenceImage.name ==  "Freedom"{
                    state3 = state
                }else if imageAnchor.referenceImage.name ==  "n-Action"{
                    state4 = state
                }
            }
        }
      
        
        if(state1){
            self.diffView.Play()
            self.diffView.playerLayer.player?.volume = 0.8
        }else {
            self.diffView.Pause()
        }
        if(state2){
            self.globalView.Play()
            self.globalView.playerLayer.player?.volume = 0.8
        }else{
            self.globalView.Pause()
        }
        if(state4){
            self.actionView.Play()
            self.actionView.playerLayer.player?.volume = 0.8
        }else{
            self.actionView.Pause()
        }
        if(state3){
            self.freedomView.Play()
            self.freedomView.playerLayer.player?.volume = 0.8
        }else{
            self.freedomView.Pause()
        }
//        state1 = false
//        state2 = false
//        state3 = false
//        state4 = false
    }
    @objc func tickUp()
    {
       
    }
    // MARK: - Session management (Image detection setup)
    
    /// Prevents restarting the session while a restart is in progress.
    var isRestartAvailable = true
    
    @IBAction func switchOnMagic(_ sender: Any) {
        let configuration = ARImageTrackingConfiguration()
        
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
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
        // Show video overlaid on image
        if let imageAnchor = anchor as? ARImageAnchor {
            // Create a plane
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            if imageAnchor.referenceImage.name == "Different Countries" {
                plane.firstMaterial?.diffuse.contents = self.diffView.playerLayer.player
            }else if imageAnchor.referenceImage.name ==  "global"{
                plane.firstMaterial?.diffuse.contents = self.globalView.playerLayer.player
            }else if imageAnchor.referenceImage.name ==  "Freedom"{
                plane.firstMaterial?.diffuse.contents = self.freedomView.playerLayer.player
            }else if imageAnchor.referenceImage.name ==  "n-Action"{
                plane.firstMaterial?.diffuse.contents = self.actionView.playerLayer.player
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
